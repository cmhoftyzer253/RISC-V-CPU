import math
from CacheResultTransaction import StatusEnum, CacheResultTransaction

Writeback = tuple[int, list[int]]

class CacheLine:
    def __init__(self):
        self.tag = 0
        self.valid = False
        self.dirty = False
        self.data = []

    def __str__(self):
        string = f"V: {self.valid}, D: {self.dirty}, Tag: {hex(self.tag)}"
        string += "Data: " + "".join(f"{entry:016x}" for entry in self.data)
        return string

    def __repr__(self):
        return self.__str__()

    def writeentry(self, entrynum, bitmask, data):
        olddata = self.data[entrynum]
        writedata = (olddata & ~bitmask) | (data & bitmask)
        self.data[entrynum] = writedata

class Cache:
    def __init__(self, bytesperentry, numways, numsets, addrlen, taglen, mem):
        self.numways = numways
        self.numsets = numsets

        self.addrlen = addrlen
        self.taglen = taglen
        self.setlen = int(math.log(numsets, 2))
        self.offsetlen = self.addrlen - self.taglen - self.setlen

        self.bytesperentry = bytesperentry
        self.bytesperline = 2 ** self.offsetlen
        self.entriesperline = self.bytesperline // self.bytesperentry

        self.mem = mem

        self.ways = []
        for i in range(numways):
            self.ways.append([])
            for _ in range(self.numsets):
                self.ways[i].append(CacheLine())

        self.pLRU = []
        for i in range(self.numsets):
            self.pLRU.append([0]*(self.numways-1))

    def clean(self) -> list[Writeback]:
        """
        Writeback dirty lines to memory
        Returns one writeback transaction per valid dirty line in increasing way, set order
        Transactions are tuples of form (baseaddress, [entry0, entry1, ... , entryn]), all of datatype int
        """

        writebacks = []

        for way in self.ways:
            for setnum, line in enumerate(way):
                if line.dirty and line.valid:
                    baseaddr = (line.tag << (self.setlen + self.offsetlen)) | (setnum << self.offsetlen)

                    for entrynum, entry in enumerate(line.data):
                        addr = baseaddr + entrynum * self.bytesperentry
                        self.mem[addr] = entry

                    writebacks.append((baseaddr, list(line.data)))

                line.dirty = False

        return writebacks

    def invalidate(self):
        for way in self.ways:
            for line in way:
                line.valid = False

    def clear_pLRU(self):
        self.pLRU = []
        for _ in range(self.numsets):
            self.pLRU.append([0]*(self.numways-1))

    def splitaddr(self, addr):
        """
        produce tag, set index, line entry number from address
        """
        tag = addr >> (self.setlen + self.offsetlen) & int('1'*self.taglen, 2)
        setnum = (addr >> self.offsetlen) & int('1'*self.setlen, 2)
        offset = addr & int('1'*self.offsetlen, 2)
        entrynum = offset // self.bytesperentry
        return tag, setnum, entrynum

    def cacheaccess(self, addr, data=None, write=False, bytemask=0xFF) -> CacheResultTransaction:
        res = CacheResultTransaction()
        tag, setnum, entrynum = self.splitaddr(addr)
        bitmask = self.write_bitmask(bytemask)

        for waynum in range(self.numways):
            line = self.ways[waynum][setnum]
            if line.tag == tag and line.valid:
                line.dirty = line.dirty or write
                self.update_pLRU(waynum, setnum)
                if write:
                    line.writeentry(entrynum, bitmask, data)

                res.accesstype = StatusEnum.H
                res.data = None if write else line.data[entrynum]
                return res

        for waynum in range(self.numways):
            line = self.ways[waynum][setnum]
            if not line.valid:
                line.tag = tag
                line.valid = True
                line.dirty = write
                self.update_pLRU(waynum, setnum)

                baseaddr = (tag << (self.setlen + self.offsetlen)) | (setnum << self.offsetlen)
                lineentries = [self.mem.get(baseaddr + i*self.bytesperentry, 0) for i in range(self.entriesperline)]
                line.data = lineentries

                if write:
                    line.writeentry(entrynum, bitmask, data)

                res.accesstype = StatusEnum.R
                res.data = None if write else line.data[entrynum]
                res.refilladdr = baseaddr
                return res

        victim = self.getvictimway(setnum)
        line = self.ways[victim][setnum]

        if line.dirty:
            writebackaddr = (line.tag << (self.setlen + self.offsetlen)) | (setnum << self.offsetlen)
            for i, entry in enumerate(line.data):
                self.mem[writebackaddr + i * self.bytesperentry] = entry

            res.accesstype = StatusEnum.D
            res.writebackaddr = writebackaddr
            res.writebackdata = list(line.data)
        else:
            res.accesstype = StatusEnum.R

        line.tag = tag
        line.valid = True
        line.dirty = write
        baseaddr = (tag << (self.setlen + self.offsetlen)) | (setnum << self.offsetlen)
        lineentries = [self.mem.get(baseaddr + i*self.bytesperentry, 0) for i in range(self.entriesperline)]
        line.data = lineentries
        self.update_pLRU(victim, setnum)
        if write:
            line.writeentry(entrynum, bitmask, data)

        res.data = None if write else line.data[entrynum]
        res.refilladdr = baseaddr
        return res

    def write_bitmask(self, bytemask):
        bitmask = 0
        for i in range(self.bytesperentry):
            if (bytemask >> i) & 1:
                bitmask |= 0xFF << (8*i)

        return bitmask

    def update_pLRU(self, waynum, setnum):
        if self.numways == 1:
            return

        tree = self.pLRU[setnum]
        bottomrow = (self.numways -1)//2
        index = (waynum // 2) + bottomrow
        tree[index] = int(not waynum % 2)
        while index > 0:
            parent = (index-1) // 2
            tree[parent] = index % 2
            index = parent

    def getvictimway(self, setnum):
        if self.numways == 1:
            return 0

        tree = self.pLRU[setnum]
        index = 0
        bottomrow = (self.numways - 1) // 2
        while index < bottomrow:
            if tree[index] == 0:
                index = index*2 + 1
            else:
                index = index*2 + 2

        victim = (index - bottomrow)*2
        if tree[index] == 1:
            victim += 1

        return victim

    def __str__(self):
        string = ""
        for i in range(self.numways):
            string += f"Way {i}:"
            for line in self.ways[i]:
                string += f"{line}, "
            string += "\n\n"
        return string

    def __repr__(self):
        return self.__str__()
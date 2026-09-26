const Block = struct {
    addr: u32,
    size: u32,

    fn add(self: Block, other: Block) Block {
        if (self.addr + self.size != other.addr)
            @panic("Blocks must be adjacent");
        return Block{
            .addr = self.addr,
            .size = self.size + other.size,
        };
    }
};

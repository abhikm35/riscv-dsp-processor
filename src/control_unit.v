//=============================================================================
// Control Unit for RISC-V DSP Processor
// Handles pipeline control, hazard detection, and forwarding
//=============================================================================

module control_unit (
    input wire clk,
    input wire rst_n,
    input wire [31:0] instruction,
    input wire [4:0]  rd_ex,    // Destination register in EX stage
    input wire [4:0]  rd_mem,   // Destination register in MEM stage
    input wire [4:0]  rd_wb,    // Destination register in WB stage
    input wire        reg_write_ex,  // Register write in EX stage
    input wire        reg_write_mem, // Register write in MEM stage
    input wire        reg_write_wb,  // Register write in WB stage
    input wire        mem_read_ex,   // Memory read in EX stage
    input wire        branch_taken,  // Branch taken signal
    input wire        jump_taken,    // Jump taken signal
    output reg        pc_stall,      // PC stall signal
    output reg        if_stall,      // IF stage stall
    output reg        id_stall,      // ID stage stall
    output reg        ex_stall,      // EX stage stall
    output reg        mem_stall,     // MEM stage stall
    output reg        wb_stall,      // WB stage stall
    output reg        if_flush,      // IF stage flush
    output reg        id_flush,      // ID stage flush
    output reg        ex_flush,      // EX stage flush
    output reg        mem_flush,     // MEM stage flush
    output reg        wb_flush,      // WB stage flush
    output reg [1:0]  forward_a,     // Forwarding for operand A
    output reg [1:0]  forward_b,     // Forwarding for operand B
    output reg        hazard_detected // Hazard detection flag
);

    // Internal signals
    wire [4:0] rs1, rs2;
    wire [4:0] rd;
    wire reg_write, mem_read, branch, jump;
    
    // Extract instruction fields
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    
    // Decode control signals
    assign reg_write = (instruction[6:0] == 7'b0110011) || // R-type
                      (instruction[6:0] == 7'b0010011) || // I-type
                      (instruction[6:0] == 7'b0000011) || // Load
                      (instruction[6:0] == 7'b1101111) || // JAL
                      (instruction[6:0] == 7'b1100111) || // JALR
                      (instruction[6:0] == 7'b0001011);   // Custom DSP
    
    assign mem_read = (instruction[6:0] == 7'b0000011);
    assign branch = (instruction[6:0] == 7'b1100011);
    assign jump = (instruction[6:0] == 7'b1101111) || (instruction[6:0] == 7'b1100111);
    
    // Hazard detection
    always @(*) begin
        hazard_detected = 1'b0;
        
        // Load-use hazard: Load instruction followed by instruction that uses the result
        if (mem_read_ex && ((rs1 == rd_ex) || (rs2 == rd_ex))) begin
            hazard_detected = 1'b1;
        end
        
        // Data hazard: EX stage writes to register used by current instruction
        if (reg_write_ex && rd_ex != 5'h0 && ((rs1 == rd_ex) || (rs2 == rd_ex))) begin
            hazard_detected = 1'b1;
        end
    end
    
    // Forwarding logic
    always @(*) begin
        forward_a = 2'b00; // No forwarding
        forward_b = 2'b00; // No forwarding
        
        // Forward from MEM stage
        if (reg_write_mem && rd_mem != 5'h0 && rs1 == rd_mem) begin
            forward_a = 2'b10; // Forward from MEM stage
        end else if (reg_write_mem && rd_mem != 5'h0 && rs2 == rd_mem) begin
            forward_b = 2'b10; // Forward from MEM stage
        end
        
        // Forward from WB stage (if not forwarding from MEM)
        if (reg_write_wb && rd_wb != 5'h0 && rs1 == rd_wb && !(reg_write_mem && rd_mem != 5'h0 && rs1 == rd_mem)) begin
            forward_a = 2'b01; // Forward from WB stage
        end else if (reg_write_wb && rd_wb != 5'h0 && rs2 == rd_wb && !(reg_write_mem && rd_mem != 5'h0 && rs2 == rd_mem)) begin
            forward_b = 2'b01; // Forward from WB stage
        end
    end
    
    // Stall and flush control
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_stall <= 1'b0;
            if_stall <= 1'b0;
            id_stall <= 1'b0;
            ex_stall <= 1'b0;
            mem_stall <= 1'b0;
            wb_stall <= 1'b0;
            if_flush <= 1'b0;
            id_flush <= 1'b0;
            ex_flush <= 1'b0;
            mem_flush <= 1'b0;
            wb_flush <= 1'b0;
        end else begin
            // Default values
            pc_stall <= 1'b0;
            if_stall <= 1'b0;
            id_stall <= 1'b0;
            ex_stall <= 1'b0;
            mem_stall <= 1'b0;
            wb_stall <= 1'b0;
            if_flush <= 1'b0;
            id_flush <= 1'b0;
            ex_flush <= 1'b0;
            mem_flush <= 1'b0;
            wb_flush <= 1'b0;
            
            // Load-use hazard: Stall IF and ID stages
            if (hazard_detected) begin
                pc_stall <= 1'b1;
                if_stall <= 1'b1;
                id_stall <= 1'b1;
                ex_flush <= 1'b1; // Flush EX stage to insert bubble
            end
            
            // Branch/Jump taken: Flush IF and ID stages
            if (branch_taken || jump_taken) begin
                if_flush <= 1'b1;
                id_flush <= 1'b1;
                ex_flush <= 1'b1;
            end
        end
    end

endmodule

pragma solidity ^0.8.0;

contract JutsuPay {
    
    enum Status { PENDING, COMPLETED, FAILED }
    
    struct Transfer {
        uint256 id;
        string fromAccount;
        string toAccount;
        uint256 amount;
        Status status;
        uint256 timestamp;
    }
    
    Transfer[] public transferi;
    
    uint256 private nextId = 1;
    
    uint256 public constant PRAG_VERIFIKACIJE = 50000;
    
    event TransferZabelezen(
        uint256 id,
        string fromAccount,
        string toAccount,
        uint256 amount,
        Status status
    );
    
    event TransferVerifikovan(uint256 id);
    
    function zabeleziTransfer(
        string memory fromAccount,
        string memory toAccount,
        uint256 amount
    ) public returns (uint256) {
        
        Status status;
        if (amount > PRAG_VERIFIKACIJE) {
            status = Status.PENDING;
        } else {
            status = Status.COMPLETED;
        }
        
        Transfer memory noviTransfer = Transfer({
            id: nextId,
            fromAccount: fromAccount,
            toAccount: toAccount,
            amount: amount,
            status: status,
            timestamp: block.timestamp
        });
        
        transferi.push(noviTransfer);
        
        emit TransferZabelezen(nextId, fromAccount, toAccount, amount, status);
        
        nextId++;
        return noviTransfer.id;
    }
    
    function verifikujTransfer(uint256 transferId) public {
        require(transferId > 0 && transferId < nextId, "Transfer ne postoji");
        
        uint256 index = transferId - 1;
        
        require(transferi[index].status == Status.PENDING, "Transfer nije PENDING");
        
        transferi[index].status = Status.COMPLETED;
        
        emit TransferVerifikovan(transferId);
    }
    
    function getTransakcije(string memory accountNumber) 
        public 
        view 
        returns (Transfer[] memory) 
    {
        uint256 broj = 0;
        for (uint256 i = 0; i < transferi.length; i++) {
            if (
                keccak256(bytes(transferi[i].fromAccount)) == keccak256(bytes(accountNumber)) ||
                keccak256(bytes(transferi[i].toAccount)) == keccak256(bytes(accountNumber))
            ) {
                broj++;
            }
        }
        
        Transfer[] memory rezultat = new Transfer[](broj);
        uint256 j = 0;
        for (uint256 i = 0; i < transferi.length; i++) {
            if (
                keccak256(bytes(transferi[i].fromAccount)) == keccak256(bytes(accountNumber)) ||
                keccak256(bytes(transferi[i].toAccount)) == keccak256(bytes(accountNumber))
            ) {
                rezultat[j] = transferi[i];
                j++;
            }
        }
        
        return rezultat;
    }
    
    function getBrojTransfera() public view returns (uint256) {
        return transferi.length;
    }
}

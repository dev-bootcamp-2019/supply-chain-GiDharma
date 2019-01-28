pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    uint public initialBalance = 1 ether;
    SupplyChain sc;
    User seller;
    User buyer;
    User owner;

    constructor() public payable{}

    function beforeAll() public{
        Assert.equal(address(this).balance, 1 ether, "Contract was not deployed with initial balance of 1 ether");

        sc = SupplyChain(DeployedAddresses.SupplyChain());    
        
        seller = new User();
        buyer = (new User).value(100)();

        //Add a few items for testing
        seller.addItem(sc, "Item #1", 10);
        seller.addItem(sc, "Item #2", 10);
        
        //Buy Second Item
        buyer.buyItem(address(sc), 1, 10);
    }

    // buyItem

    // test for failure if user does not send enough funds
    function testBuyItemNotEnoughFunds() public {
        uint sku = 0;
        (bool txFailed, ) = address(buyer).call(
            abi.encodeWithSignature("buyItem(address,uint256,uint256)", address(sc), sku, 1));
        
        Assert.isFalse(txFailed, "Not enough funds were sent!");
    }

    // test for purchasing an item that is not for Sale
    function testBuyItemNotForSale() public {
        uint sku = 1;
        
        (bool txFailed, ) = address(buyer).call(
            abi.encodeWithSignature("buyItem(address,uint256,uint256)", address(sc), sku, 10));
        
        Assert.isFalse(txFailed, "Item was already sold!");
    }
    
    // shipItem

    // test for calls that are made by not the seller
    function testShipItemNotSeller() public {
        uint sku = 1;
        
        (bool txFailed, ) = address(buyer).call(
            abi.encodeWithSignature("shipItem(address,uint256)", address(sc), sku));
        
        Assert.isFalse(txFailed, "Not the seller that is shipping the item!");
    }

    // test for trying to ship an item that is not marked Sold
    function testShipItemNotSold() public {
        uint sku = 0;
        
        (bool txFailed, ) = address(seller).call(
            abi.encodeWithSignature("shipItem(address,uint256)", address(sc), sku));
        
        Assert.isFalse(txFailed, "Item is not sold yet!");
    }
    
    // receiveItem

    // test calling the function on an item not marked Shipped
    function testReceiveItemNotShipped() public {
        uint sku = 1;

        (bool txFailed, ) = address(buyer).call(
            abi.encodeWithSignature("receiveItem(address,uint256)", address(sc), sku));
        
        Assert.isFalse(txFailed, "Item was not shipped!");
    }

    
    // test calling the function from an address that is not the buyer
    function testReceiveItemNotBuyer() public {
        uint sku = 1;

        seller.shipItem(address(sc),sku);
        (bool txFailed, ) = address(seller).call(
            abi.encodeWithSignature("receiveItem(address,uint256)", address(sc), sku));
        
        Assert.isFalse(txFailed, "It is not the buyer!");
    }

    function() external{
    }
}

contract User {

    constructor() public payable{}

    // Functions for the seller
    function addItem(SupplyChain _supplyChain, string memory _item, uint _price) public returns (bool) {
        
        return _supplyChain.addItem(_item, _price);
    }

    function shipItem(address _supplyChain, uint _sku) public {
        SupplyChain test_sc = SupplyChain(_supplyChain);
        test_sc.shipItem(_sku);
    }

    // Functions for the buyer
    function buyItem(address _supplyChain, uint _sku, uint amount) public{
         SupplyChain test_sc = SupplyChain(_supplyChain);
        test_sc.buyItem.value(amount)(_sku);

    }

    function receiveItem(address _supplyChain, uint _sku) public {
        SupplyChain test_sc = SupplyChain(_supplyChain);
        test_sc.receiveItem(_sku);
    }

    function() external payable {}
}
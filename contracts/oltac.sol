pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";





contract Oltac is ERC20, ERC20Burnable, Ownable {

  

    uint tokenPrice ;

   
  constructor( uint _tokenprice, uint _numberOfToken) ERC20("Oltac", "olt") {

    tokenPrice = _tokenprice;
   _mint(msg.sender, _numberOfToken * (10 ** 18));

  }

  function buyOlt( uint _amount) public payable {

    // EOA can buy oltac token for a price
      uint topay = getTotalPrice(_amount); 

      console.log("amount to pay:",topay);

      require(msg.value >= topay, " you don't have enough money" );

      approve(msg.sender, _amount);

      transferFrom(owner(), msg.sender, _amount);
    

  }
    

//   function swap(_uint _amount) public payable {

//   }
    


//   ------------------------------------------getters---------------------------

function getPrice() public view returns (uint) {
  return tokenPrice;
}

function getDeployer() public view returns (address) {
 return owner();
}

function getTotalPrice(uint _amount ) public view returns (uint) {
 return tokenPrice * _amount;
}

}
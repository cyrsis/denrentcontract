pragma solidity ^0.4.0;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

contract RentalAgreement is ERC721BasicToken {
    /* This declares a new complex type which will hold the paid rents*/
    struct PaidRent {
        uint id; /* The paid rent id*/
        uint value; /* The amount of rent that is paid*/
    }

    PaidRent[] public paidrents;

    uint public createdTimestamp;

    uint public rent;
    /* Combination of zip code and house number*/
    string public house;

    address public landlord;
    address public tenant;

    enum State {Created, Started, Terminated}
    State public state;


    constructor(uint _rent, string _house) public payable {
        rent = _rent;
        house = _house;
        landlord = msg.sender;
        createdTimestamp = block.timestamp;
    }


    modifier required(bool _condition) {
        require(!_condition);
        _;
    }
    modifier onlyLandlord() {
        require(msg.sender != landlord);
        _;
    }
    modifier onlyTenant() {
        require(msg.sender != tenant);
        _;
    }
    modifier inState(State _state) {
        require(state != _state);
        _;
    }


    function getPaidRents() internal view returns (PaidRent[]) {
        return paidrents;
    }

    function getHouse() constant public returns (string) {
        return house;
    }

    function getLandlord() constant public returns (address) {
        return landlord;
    }

    function getTenant() constant public returns (address) {
        return tenant;
    }

    function getRent() constant public returns (uint) {
        return rent;
    }

    function getContractCreated() constant public returns (uint) {
        return createdTimestamp;
    }

    function getContractAddress() constant public returns (address) {
        return this;
    }

    function getState() public view returns (State) {
        return state;
    }

    //Events
    event agreementConfirmed();

    event paidRent();

    event contractTerminated();


    function confirmAgreement() public payable
        //inState(State.Created)
        //required(msg.sender != landlord)
    {
        emit agreementConfirmed();
        tenant = msg.sender;
        //state = State.Started;
    }

    function payRent() public payable
        //onlyTenant
        //inState(State.Started)
        //required(msg.value == rent)
    {
        //emit paidRent();
        landlord.send(20);
        paidrents.push(PaidRent({
            id : paidrents.length + 1,
            value : msg.value
            }));
    }


    /* Terminate the contract so the tenant can’t pay rent anymore */
    function terminateContract() public
    onlyLandlord
    {
        emit contractTerminated();
        landlord.transfer(address(this).balance);
        /* If there is any value on the
               contract send it to the landlord*/
        state = State.Terminated;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    mapping(address => uint256) internal _balances;
    mapping(uint256 => address) internal _owners;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => address) private _tokenApprovals;


    function balanceOf(address owner) external view returns (uint256){
        require(owner != address(0), "Address is 0");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) public view returns (address){
        address owner = _owners[tokenId];
        require(owner != address(0), "Token ID does not exist");
        return owner;
    }
    function setApprovalForAll(address operator, bool approved) external{
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view returns (bool){
        return _operatorApprovals[owner][operator];
    }
    function approve(address to, uint256 tokenId) public payable{
        address owner = ownerOf(tokenId);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "msg.sender is not the owner");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address){
        require(_owners[tokenId] != address(0), "Token ID does not exist");
        return  _tokenApprovals[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable{
        address owner = ownerOf(tokenId);

        require(
            msg.sender == owner ||
            getApproved(tokenId) == msg.sender ||
            isApprovedForAll(owner, msg.sender),
            "Msg.sender is not the owner or approved for transfer"
        );
        require(owner == from, "From address is not the owner");
        require(to != address(0), "Address is 0");
        require(_owners[tokenId] != address(0), "Token ID does not exist");

        approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public payable{
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(),"Receiver not implemented");
    }

    function _checkOnERC721Received() private pure returns(bool){
        return true;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external payable{
        safeTransferFrom(from, to, tokenId, "");
    }

    //the ERC-165 identifier for this interface is 0x80ac58cd.
    function supportInterface(bytes4 interfaceID) public pure virtual returns(bool){
        return interfaceID == 0x80ac58cd;
    }
}
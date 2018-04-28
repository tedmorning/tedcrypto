// TEDEcosystem Source code
pragma solidity ^0.4.11;
contract Ownable {
  address public owner;
  function Ownable() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}
contract ERC721 {
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}
contract tedxcienceInterface {
    function istedxcience() public pure returns (bool);
    function mixtedx(uint256 tedx1, uint256 tedx2, uint256 targetBlock) public returns (uint256);
}
contract TEDAccessControl {
    event ContractUpgrade(address newContract);
    address public tedaAddress;
    address public tedbAddress;
    address public tedcAddress;
    bool public paused = false;
    modifier onlyteda() {
        require(msg.sender == tedaAddress);
        _;
    }
    modifier onlytedb() {
        require(msg.sender == tedbAddress);
        _;
    }
    modifier onlytedc() {
        require(msg.sender == tedcAddress);
        _;
    }
    modifier onlyCLevel() {
        require(
            msg.sender == tedcAddress ||
            msg.sender == tedaAddress ||
            msg.sender == tedbAddress
        );
        _;
    }
    function seta(address _newa) external onlyteda {
        require(_newa != address(0));

        tedaAddress = _newa;
    }
    function setb(address _newb) external onlyteda {
        require(_newb != address(0));

        tedbAddress = _newb;
    }
    function setc(address _newc) external onlyteda {
        require(_newc != address(0));

        tedcAddress = _newc;
    }
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused {
        require(paused);
        _;
    }
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }
    function unpause() public onlyteda whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}
contract TEDBase is TEDAccessControl {
    event create(address owner, uint256 TEDId, uint256 matronId, uint256 stockId, uint256 tedx);
    event Transfer(address from, address to, uint256 tokenId);
    struct TED {
        uint256 tedx;
        uint64 createTime;
        uint64 cooldownEndBlock;
        uint32 matronId;
        uint32 stockId;
        uint32 timanId;
        uint16 cooldownIndex;
        uint16 checkx;
    }
    uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];
    uint256 public secondsPerBlock = 15;
    TED[] teds;
    mapping (uint256 => address) public TEDIndexToOwner;
    mapping (address => uint256) ownershipTokenCount;
    mapping (uint256 => address) public TEDIndexToApproved;
    mapping (uint256 => address) public stockAllowedToAddress;
    SaleClockAuction public saleAuction;
    tedingClockAuction public tedingAuction;
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;
        TEDIndexToOwner[_tokenId] = _to;
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            delete stockAllowedToAddress[_tokenId];
            delete TEDIndexToApproved[_tokenId];
        }
        Transfer(_from, _to, _tokenId);
    }
    function _createTED(
        uint256 _matronId,
        uint256 _stockId,
        uint256 _checkx,
        uint256 _tedx,
        address _owner
    )
        internal
        returns (uint)
    {
        require(_matronId == uint256(uint32(_matronId)));
        require(_stockId == uint256(uint32(_stockId)));
        require(_checkx == uint256(uint16(_checkx)));
        uint16 cooldownIndex = uint16(_checkx / 2);
        if (cooldownIndex > 13) {
            cooldownIndex = 13;
        }
        TED memory _TED = TED({
            tedx: _tedx,
            createTime: uint64(now),
            cooldownEndBlock: 0,
            matronId: uint32(_matronId),
            stockId: uint32(_stockId),
            timanId: 0,
            cooldownIndex: cooldownIndex,
            checkx: uint16(_checkx)
        });
        uint256 newtedenId = teds.push(_TED) - 1;
        require(newtedenId == uint256(uint32(newtedenId)));
        create(
            _owner,
            newtedenId,
            uint256(_TED.matronId),
            uint256(_TED.stockId),
            _TED.tedx
        );
        _transfer(0, _owner, newtedenId);
        return newtedenId;
    }
    function setSecondsPerBlock(uint256 secs) external onlyCLevel {
        require(secs < cooldowns[0]);
        secondsPerBlock = secs;
    }
}
contract ERC721Metadata {
    function getMetadata(uint256 _tokenId, string) public view returns (bytes32[4] buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hello World! :D";
            count = 15;
        } else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        } else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            count = 128;
        }
    }
}
contract TEDOwnership is TEDBase, ERC721 {
    string public constant name = "TEDEcosystem";
    string public constant symbol = "CK";
    ERC721Metadata public erc721Metadata;
    bytes4 constant InterfaceSignature_ERC165 =
    bytes4(keccak256('supportsInterface(bytes4)'));
    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }
    function setMetadataAddress(address _contractAddress) public onlyteda {
        erc721Metadata = ERC721Metadata(_contractAddress);
    }
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return TEDIndexToOwner[_tokenId] == _claimant;
    }
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return TEDIndexToApproved[_tokenId] == _claimant;
    }
    function _approve(uint256 _tokenId, address _approved) internal {
        TEDIndexToApproved[_tokenId] = _approved;
    }
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }
    function transfer(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        require(_to != address(0));
        require(_to != address(this));
        require(_to != address(saleAuction));
        require(_to != address(tedingAuction));
        require(_owns(msg.sender, _tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        require(_owns(msg.sender, _tokenId));
        _approve(_tokenId, _to);
        Approval(msg.sender, _to, _tokenId);
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        require(_to != address(0));
        require(_to != address(this));
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));
        _transfer(_from, _to, _tokenId);
    }
    function totalSupply() public view returns (uint) {
        return teds.length - 1;
    }
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = TEDIndexToOwner[_tokenId];
        require(owner != address(0));
    }
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 tedtotals = totalSupply();
            uint256 resultIndex = 0;
            uint256 tedId;
            for (tedId = 1; tedId <= tedtotals; tedId++) {
                if (TEDIndexToOwner[tedId] == _owner) {
                    result[resultIndex] = tedId;
                    resultIndex++;
                }
            }
            return result;
        }
    }
    function _memcpy(uint _dest, uint _src, uint _len) private view {
        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }
        uint256 mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }
    function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private view returns (string) {
        var outputString = new string(_stringLength);
        uint256 outputPtr;
        uint256 bytesPtr;
        assembly {
            outputPtr := add(outputString, 32)
            bytesPtr := _rawBytes
        }
        _memcpy(outputPtr, bytesPtr, _stringLength);
        return outputString;
    }
    function tokenMetadata(uint256 _tokenId, string _preferredTransport) external view returns (string infoUrl) {
        require(erc721Metadata != address(0));
        bytes32[4] memory buffer;
        uint256 count;
        (buffer, count) = erc721Metadata.getMetadata(_tokenId, _preferredTransport);
        return _toString(buffer, count);
    }
}
contract TEDPlay is TEDOwnership {
    event Pregnant(address owner, uint256 matronId, uint256 stockId, uint256 cooldownEndBlock);
    uint256 public autocreateFee = 2 finney;
    uint256 public pregnantteds;
    tedxcienceInterface public tedxcience;
    function settedxcienceAddress(address _address) external onlyteda {
        tedxcienceInterface candidateContract = tedxcienceInterface(_address);
        require(candidateContract.istedxcience());
        tedxcience = candidateContract;
    }
    function _isReadyToPlay(TED _kit) internal view returns (bool) {
        return (_kit.timanId == 0) && (_kit.cooldownEndBlock <= uint64(block.number));
    }
    function _istedingPermitted(uint256 _stockId, uint256 _matronId) internal view returns (bool) {
        address matronOwner = TEDIndexToOwner[_matronId];
        address stockOwner = TEDIndexToOwner[_stockId];
        return (matronOwner == stockOwner || stockAllowedToAddress[_stockId] == matronOwner);
    }
    function _triggerCooldown(TED storage _teden) internal {
        _teden.cooldownEndBlock = uint64((cooldowns[_teden.cooldownIndex]/secondsPerBlock) + block.number);
        if (_teden.cooldownIndex < 13) {
            _teden.cooldownIndex += 1;
        }
    }
    function approveteding(address _addr, uint256 _stockId)
        external
        whenNotPaused
    {
        require(_owns(msg.sender, _stockId));
        stockAllowedToAddress[_stockId] = _addr;
    }
    function setAutocreateFee(uint256 val) external onlytedc {
        autocreateFee = val;
    }
    function _isReadyToGivecreate(TED _matron) private view returns (bool) {
        return (_matron.timanId != 0) && (_matron.cooldownEndBlock <= uint64(block.number));
    }
    function isReadyToPlay(uint256 _TEDId)
        public
        view
        returns (bool)
    {
        require(_TEDId > 0);
        TED storage kit = teds[_TEDId];
        return _isReadyToPlay(kit);
    }
    function isPregnant(uint256 _TEDId)
        public
        view
        returns (bool)
    {
        require(_TEDId > 0);
        // A TED is pregnant if and only if this field is set
        return teds[_TEDId].timanId != 0;
    }
    function _isValidMatingPair(
        TED storage _matron,
        uint256 _matronId,
        TED storage _stock,
        uint256 _stockId
    )
        private
        view
        returns(bool)
    {
        if (_matronId == _stockId) {
            return false;
        }
        if (_matron.matronId == _stockId || _matron.stockId == _stockId) {
            return false;
        }
        if (_stock.matronId == _matronId || _stock.stockId == _matronId) {
            return false;
        }
        if (_stock.matronId == 0 || _matron.matronId == 0) {
            return true;
        }
        if (_stock.matronId == _matron.matronId || _stock.matronId == _matron.stockId) {
            return false;
        }
        if (_stock.stockId == _matron.matronId || _stock.stockId == _matron.stockId) {
            return false;
        }
        return true;
    }
    function _tedcombViaAuction(uint256 _matronId, uint256 _stockId)
        internal
        view
        returns (bool)
    {
        TED storage matron = teds[_matronId];
        TED storage stock = teds[_stockId];
        return _isValidMatingPair(matron, _matronId, stock, _stockId);
    }
    function tedcomb(uint256 _matronId, uint256 _stockId)
        external
        view
        returns(bool)
    {
        require(_matronId > 0);
        require(_stockId > 0);
        TED storage matron = teds[_matronId];
        TED storage stock = teds[_stockId];
        return _isValidMatingPair(matron, _matronId, stock, _stockId) &&
            _istedingPermitted(_stockId, _matronId);
    }
    function _tedwt(uint256 _matronId, uint256 _stockId) internal {
        TED storage stock = teds[_stockId];
        TED storage matron = teds[_matronId];
        matron.timanId = uint32(_stockId);
        _triggerCooldown(stock);
        _triggerCooldown(matron);
        delete stockAllowedToAddress[_matronId];
        delete stockAllowedToAddress[_stockId];
        pregnantteds++;
        Pregnant(TEDIndexToOwner[_matronId], _matronId, _stockId, matron.cooldownEndBlock);
    }
    function tedwtAuto(uint256 _matronId, uint256 _stockId)
        external
        payable
        whenNotPaused
    {
        require(msg.value >= autocreateFee);
        require(_owns(msg.sender, _matronId));
        require(_istedingPermitted(_stockId, _matronId));
        TED storage matron = teds[_matronId];
        require(_isReadyToPlay(matron));
        TED storage stock = teds[_stockId];
        require(_isReadyToPlay(stock));
        require(_isValidMatingPair(
            matron,
            _matronId,
            stock,
            _stockId
        ));
        _tedwt(_matronId, _stockId);
    }
    function givecreate(uint256 _matronId)
        external
        whenNotPaused
        returns(uint256)
    {
        TED storage matron = teds[_matronId];
        require(matron.createTime != 0);
        require(_isReadyToGivecreate(matron));
        uint256 stockId = matron.timanId;
        TED storage stock = teds[stockId];
        uint16 parentGen = matron.checkx;
        if (stock.checkx > matron.checkx) {
            parentGen = stock.checkx;
        }
        uint256 childtedx = tedxcience.mixtedx(matron.tedx, stock.tedx, matron.cooldownEndBlock - 1);
        address owner = TEDIndexToOwner[_matronId];
        uint256 tedenId = _createTED(_matronId, matron.timanId, parentGen + 1, childtedx, owner);
        delete matron.timanId;
        pregnantteds--;
        msg.sender.send(autocreateFee);
        return tedenId;
    }
}
contract ClockAuctionBase {
    struct Auction {
        address seller;
        uint128 startingPrice;
        uint128 endingPrice;
        uint64 duration;
        uint64 startedAt;
    }
    ERC721 public nonFungibleContract;
    uint256 public ownerCut;
    mapping (uint256 => Auction) tokenIdToAuction;
    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }
    function _escrow(address _owner, uint256 _tokenId) internal {
        nonFungibleContract.transferFrom(_owner, this, _tokenId);
    }
    function _transfer(address _receiver, uint256 _tokenId) internal {
        nonFungibleContract.transfer(_receiver, _tokenId);
    }
    function _addAuction(uint256 _tokenId, Auction _auction) internal {
        require(_auction.duration >= 1 minutes);
        tokenIdToAuction[_tokenId] = _auction;
        AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration)
        );
    }
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        AuctionCancelled(_tokenId);
    }
    function _bid(uint256 _tokenId, uint256 _bidAmount)
        internal
        returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);
        address seller = auction.seller;
        _removeAuction(_tokenId);
        if (price > 0) {
            uint256 auctioneerCut = _computeCut(price);
            seller.transfer(sellerProceeds);
        }
        uint256 bidExcess = _bidAmount - price;
        msg.sender.transfer(bidExcess);
        AuctionSuccessful(_tokenId, price, msg.sender);
        return price;
    }
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }
    function _currentPrice(Auction storage _auction)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;
        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }
        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
        if (_secondsPassed >= _duration) {
            return _endingPrice;
        } else {
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;
            return uint256(currentPrice);
        }
    }
    function _computeCut(uint256 _price) internal view returns (uint256) {
        return _price * ownerCut / 10000;
    }

}
contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  modifier whenPaused {
    require(paused);
    _;
  }
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}
contract ClockAuction is Pausable, ClockAuctionBase {
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);
    function ClockAuction(address _nftAddress, uint256 _cut) public {
        require(_cut <= 10000);
        ownerCut = _cut;
        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        nonFungibleContract = candidateContract;
    }
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);
        require(
            msg.sender == owner ||
            msg.sender == nftAddress
        );
        bool res = nftAddress.send(this.balance);
    }
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
        whenNotPaused
    {
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));
        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }
    function bid(uint256 _tokenId)
        external
        payable
        whenNotPaused
    {
        _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
    }
    function cancelAuction(uint256 _tokenId)
        external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }
    function cancelAuctionWhenPaused(uint256 _tokenId)
        whenPaused
        onlyOwner
        external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }
    function getAuction(uint256 _tokenId)
        external
        view
        returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            auction.startedAt
        );
    }
    function getCurrentPrice(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

}
contract tedingClockAuction is ClockAuction {
    bool public istedingClockAuction = true;
    function tedingClockAuction(address _nftAddr, uint256 _cut) public
    ClockAuction(_nftAddr, _cut) {}
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
    {
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));
        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }
    function bid(uint256 _tokenId)
        external
        payable
    {
        require(msg.sender == address(nonFungibleContract));
        address seller = tokenIdToAuction[_tokenId].seller;
        _bid(_tokenId, msg.value);
        _transfer(seller, _tokenId);
    }

}
contract SaleClockAuction is ClockAuction {
    bool public isSaleClockAuction = true;
    uint256 public gen0SaleCount;
    uint256[5] public lastGen0SalePrices;
    function SaleClockAuction(address _nftAddr, uint256 _cut) public
    ClockAuction(_nftAddr, _cut) {}
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
    {
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));
        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }
    function bid(uint256 _tokenId)
        external
        payable
    {
        address seller = tokenIdToAuction[_tokenId].seller;
        uint256 price = _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
        if (seller == address(nonFungibleContract)) {
            // Track gen0 sale prices
            lastGen0SalePrices[gen0SaleCount % 5] = price;
            gen0SaleCount++;
        }
    }
    function averageGen0SalePrice() external view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += lastGen0SalePrices[i];
        }
        return sum / 5;
    }
}
contract TEDAuction is TEDPlay {
    function setSaleAuctionAddress(address _address) external onlyteda {
        SaleClockAuction candidateContract = SaleClockAuction(_address);
		require(candidateContract.isSaleClockAuction());
        saleAuction = candidateContract;
    }
    function settedingAuctionAddress(address _address) external onlyteda {
        tedingClockAuction candidateContract = tedingClockAuction(_address);
		require(candidateContract.istedingClockAuction());
        tedingAuction = candidateContract;
    }
    function createSaleAuction(
        uint256 _TEDId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        require(_owns(msg.sender, _TEDId));
        require(!isPregnant(_TEDId));
        _approve(_TEDId, saleAuction);
        saleAuction.createAuction(
            _TEDId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }
    function createtedingAuction(
        uint256 _TEDId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        require(_owns(msg.sender, _TEDId));
        require(isReadyToPlay(_TEDId));
        _approve(_TEDId, tedingAuction);
        tedingAuction.createAuction(
            _TEDId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }
    function bidOntedingAuction(
        uint256 _stockId,
        uint256 _matronId
    )
        external
        payable
        whenNotPaused
    {
        require(_owns(msg.sender, _matronId));
        require(isReadyToPlay(_matronId));
        require(_tedcombViaAuction(_matronId, _stockId));
        uint256 currentPrice = tedingAuction.getCurrentPrice(_stockId);
        require(msg.value >= currentPrice + autocreateFee);
        tedingAuction.bid.value(msg.value - autocreateFee)(_stockId);
        _tedwt(uint32(_matronId), uint32(_stockId));
    }
    function withdrawAuctionBalances() external onlyCLevel {
        saleAuction.withdrawBalance();
        tedingAuction.withdrawBalance();
    }
}
contract TEDMinting is TEDAuction {
    uint256 public constant PROMO_CREATION_LIMIT = 5000;
    uint256 public constant STR0_CREATION_LIMIT = 45000;
    uint256 public constant STR0_STARTING_PRICE = 10 finney;
    uint256 public constant STR0_AUCTION_DURATION = 1 days;
    uint256 public promoCreatedCount;
    uint256 public gen0CreatedCount;
    function createPromoTED(uint256 _tedx, address _owner) external onlytedc {
        address TEDOwner = _owner;
        if (TEDOwner == address(0)) {
             TEDOwner = tedcAddress;
        }
        require(promoCreatedCount < PROMO_CREATION_LIMIT);
        promoCreatedCount++;
        _createTED(0, 0, 0, _tedx, TEDOwner);
    }
    function createGen0Auction(uint256 _tedx) external onlytedc {
        require(gen0CreatedCount < STR0_CREATION_LIMIT);
        uint256 TEDId = _createTED(0, 0, 0, _tedx, address(this));
        _approve(TEDId, saleAuction);
        saleAuction.createAuction(
            TEDId,
            _computeNextGen0Price(),
            0,
            STR0_AUCTION_DURATION,
            address(this)
        );
        gen0CreatedCount++;
    }
    function _computeNextGen0Price() internal view returns (uint256) {
        uint256 avePrice = saleAuction.averageGen0SalePrice();
        require(avePrice == uint256(uint128(avePrice)));
        uint256 nextPrice = avePrice + (avePrice / 2);
        if (nextPrice < STR0_STARTING_PRICE) {
            nextPrice = STR0_STARTING_PRICE;
        }
        return nextPrice;
    }
}
contract TEDCore is TEDMinting {
    address public newContractAddress;
    function TEDCore() public {
        paused = true;
        tedaAddress = msg.sender;
        tedcAddress = msg.sender;
        _createTED(0, 0, 0, uint256(-1), address(0));
    }
    function setNewAddress(address _v2Address) external onlyteda whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }
    function() external payable {
        require(
            msg.sender == address(saleAuction) ||
            msg.sender == address(tedingAuction)
        );
    }
    function getTED(uint256 _id)
        external
        view
        returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 timanId,
        uint256 createTime,
        uint256 matronId,
        uint256 stockId,
        uint256 checkx,
        uint256 tedx
    ) {
        TED storage kit = teds[_id];
        isGestating = (kit.timanId != 0);
        isReady = (kit.cooldownEndBlock <= block.number);
        cooldownIndex = uint256(kit.cooldownIndex);
        nextActionAt = uint256(kit.cooldownEndBlock);
        timanId = uint256(kit.timanId);
        createTime = uint256(kit.createTime);
        matronId = uint256(kit.matronId);
        stockId = uint256(kit.stockId);
        checkx = uint256(kit.checkx);
        tedx = kit.tedx;
    }
    function unpause() public onlyteda whenPaused {
        require(saleAuction != address(0));
        require(tedingAuction != address(0));
        require(tedxcience != address(0));
        require(newContractAddress == address(0));
        super.unpause();
    }
    function withdrawBalance() external onlytedb {
        uint256 balance = this.balance;
        uint256 subtractFees = (pregnantteds + 1) * autocreateFee;
        if (balance > subtractFees) {
            tedbAddress.send(balance - subtractFees);
        }
    }
}
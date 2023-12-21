// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibString} from "solady/src/utils/LibString.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {IArtistManagement} from "./interfaces/IArtistManagement.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArtistManagement is IArtistManagement, Ownable {
    IERC20 private immutable tokenAddr;

    mapping(address => uint256) public tracksCount;
    mapping(address => bytes32) public statistic;
    mapping(address => bytes32) public withdrawnRewards;

    modifier checkId(uint256 trackId) {
        if (tracksCount[msg.sender] < trackId) revert InvalidTrackId(trackId);
        _;
    }

    constructor(address _tokenAddr) payable {
        tokenAddr = IERC20(_tokenAddr);
        _initializeOwner(msg.sender);
    }

    //-----------------------STATISTIC--------------------------------------------

    function incrementTracksCount(
        address artist,
        uint256 amount
    ) external onlyOwner {
        tracksCount[artist] += amount;
        emit TracksCountIncreased(artist, amount);
    }

    function addStatistics(
        address[] calldata _artists,
        bytes32[] calldata _data
    ) external onlyOwner {
        for (uint256 i; i < _data.length; ++i) {
            statistic[_artists[i]] = _data[i];
        }
    }

    function getStatistic(
        bytes32 _hash
    ) public view returns (uint128 listens, uint64 likes, uint64 comments) {
        if (msg.sender == address(0)) revert InvalidAddress();
        assembly {
            comments := _hash
            mstore(0x18, _hash)
            listens := mload(0)
            mstore(0x8, _hash)
            likes := mload(0)
        }
    }

    function encode(
        uint128 listens,
        uint64 likes,
        uint64 comments
    ) public pure returns (bytes32 hash) {
        assembly {
            let y := 0
            mstore(0x20, comments)
            mstore(0x18, likes)
            mstore(0x8, listens)
            hash := mload(0x20)
        }
    }

    //-----------------------URI--------------------------------------------

    function trackURI(
        address artist,
        uint256 trackId
    ) external view checkId(trackId) returns (string memory) {
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length != 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        LibString.toHexString(abi.encodePacked(artist, trackId))
                    )
                )
                : "";
    }

    function _baseURI() public pure returns (string memory) {
        return "ipfs://gateaway/";
    }

    //-----------------------WITHDRAW--------------------------------------------

    function withdraw() external {
        (
            uint256 reward,
            uint128 listens,
            uint64 likes,
            uint64 comments
        ) = checkRewards(msg.sender);

        if (reward == 0) revert NothingToWithdraw();
        withdrawnRewards[msg.sender] = encode(listens, likes, comments);

        //withdraw
        bool success = tokenAddr.transfer(msg.sender, reward);
        require(success);

        emit Withdrawn(msg.sender, reward);
    }

    function checkRewards(
        address artist
    )
        public
        view
        returns (uint256 reward, uint128 listens, uint64 likes, uint64 comments)
    {
        (uint128 _listens, uint64 _likes, uint64 _comments) = getStatistic(
            statistic[artist]
        );
        (
            uint128 _withdrawnListens,
            uint64 _withdrawnLikes,
            uint64 _withdrawnComments
        ) = getStatistic(withdrawnRewards[artist]);

        listens = _listens - _withdrawnListens;
        likes = _likes - _withdrawnLikes;
        comments = _comments - _withdrawnComments;

        //imitation of price calculation
        reward = (listens + likes + comments) * 2;
    }
}

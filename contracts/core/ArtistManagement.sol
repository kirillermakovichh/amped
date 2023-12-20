// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {LibString} from "solady/src/utils/LibString.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

contract ArtistManagement is Ownable {
    uint256 private trackCount;

    mapping(address => bytes32) private statistic;
    mapping(address => bytes32) private withdrawnRewards;

    error InvalidTrackId(uint256 trackId);
    error InvalidAddress();
    error NothingToWithdraw();

    modifier checkId(uint256 trackId) {
        if (trackCount < trackId) revert InvalidTrackId(trackId);
        _;
    }

    constructor() payable {
        _initializeOwner(msg.sender);
    }

    //-----------------------STATISTIC--------------------------------------------

    function addStatistics(
        address[] calldata _artists,
        bytes32[] calldata _data
    ) external onlyOwner {
        for (uint256 i; i < _data.length; ++i) {
            statistic[_artists[i]] = _data[i];
        }
        // trackCount += i;
    }

    function getStatistic(
        bytes32 x
    ) public view returns (uint128 listens, uint64 likes, uint64 comments) {
        if (msg.sender == address(0)) revert InvalidAddress();
        // bytes32 x = statistic[_artist];
        assembly {
            comments := x
            mstore(0x18, x)
            listens := mload(0)
            mstore(0x8, x)
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
        uint256 trackId
    ) public view checkId(trackId) returns (string memory) {
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, LibString.toString(trackId)))
                : "";
    }

    function _baseURI() public pure returns (string memory) {
        return "ipfs://mdsoif/";
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

        reward = (listens + likes + comments) * 2;
    }
}

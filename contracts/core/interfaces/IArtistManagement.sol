// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IArtistManagement {
    //-----------------------STATISTIC--------------------------------------------
    function addStatistics(
        address[] calldata _artists,
        bytes32[] calldata _data
    ) external;

    function getStatistic(
        address _artist
    ) external view returns (uint128 listens, uint64 likes, uint64 comments);

    //-----------------------WITHDRAW-------------------------------------------------

    function withdraw() external;
    function checkRewards() external;
    //-----------------------URI-------------------------------------------------

    function trackURI(uint256 trackId) external view returns (string memory);

    function _baseURI() external pure returns (string memory);
}

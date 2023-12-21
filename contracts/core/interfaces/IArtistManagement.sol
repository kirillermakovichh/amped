// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IArtistManagement {
    //==================PUBLIC/EXTERNAL WRITE FUNCTIONS=====================
    function addStatistics(
        address[] calldata _artists,
        bytes32[] calldata _data
    ) external;

    function withdraw() external;

    //==================PUBLIC/EXTERNAL VIEW/PURE FUNCTIONS==================
    function checkRewards(
        address artist
    )
        external
        view
        returns (
            uint256 reward,
            uint128 listens,
            uint64 likes,
            uint64 comments
        );

    function getStatistic(
        bytes32 _hash
    ) external view returns (uint128 listens, uint64 likes, uint64 comments);

    function trackURI(
        address artist,
        uint256 trackId
    ) external view returns (string memory);

    function _baseURI() external pure returns (string memory);

    //============================EVENTS========================================

    event Withdrawn(address indexed _artist, uint256 _amount);

    event TracksCountIncreased(address indexed _artist, uint256 _trackCount);

    //============================ERRORS========================================

    error InvalidTrackId(uint256 trackId);
    error InvalidAddress();
    error NothingToWithdraw();
}

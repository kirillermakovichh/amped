// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUsersManagement {
    //==================PUBLIC/EXTERNAL WRITE FUNCTIONS=====================

    function subscribe() external returns (uint256);

    function buyTrack(address artist, uint256 trackId) external;

    function withdraw() external;

    //==================PUBLIC/EXTERNAL VIEW/PURE FUNCTIONS==================

    function checkSubscription(address user) external view returns (uint256);

    function checkRewards(address user) external view returns (uint256);

    //============================EVENTS========================================

    event SubscriptionPurchased(
        address indexed user,
        uint256 purchaseTimestamp
    );

    event Withdrawn(address indexed user, uint256 amount);

    //============================ERRORS========================================

    error AlreadySubscribed();

    error AlreadyPurchased();

    error NotSubscribed();

    error NothingToWithdraw();

    error InvalidTrackId();

    error InvalidValue();
}

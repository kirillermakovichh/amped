// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {IUsersManagement} from "./interfaces/IUsersManagement.sol";
import {IArtistManagement} from "./interfaces/IArtistManagement.sol";

contract UsersManagement is IUsersManagement {
    IArtistManagement private ArtistsManagementAddr;

    mapping(address => uint256) private subscribtions;
    mapping(address => mapping(string => bool)) private purchasedTracks;

    constructor(address _ArtistsManagementAddr) {
        ArtistsManagementAddr = IArtistManagement(_ArtistsManagementAddr);
    }

    //==================PUBLIC/EXTERNAL WRITE FUNCTIONS=====================

    function subscribe() external returns (uint256) {
        if (subscribtions[msg.sender] > block.timestamp)
            revert AlreadySubscribed();
        subscribtions[msg.sender] = block.timestamp;
        return block.timestamp;
    }

    function buyTrack(address artist, uint256 trackId) external {
        string memory trackURI = ArtistsManagementAddr.trackURI(
            artist,
            trackId
        );
        if (purchasedTracks[msg.sender][trackURI]) revert AlreadyPurchased();
        // if(ArtistsManagementAddr.tracksCount(artist) < trackId) revert InvalidTrackId();

        purchasedTracks[msg.sender][trackURI] = true;
    }

    function withdraw() external {
        uint256 reward = checkRewards(msg.sender);
    }

    //==================PUBLIC/EXTERNAL VIEW/PURE FUNCTIONS==================

    function checkSubscription(address user) external view returns (uint256) {
        return subscribtions[user];
    }

    function checkRewards(address user) public view returns (uint256) {
        return 1;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {DayNightNFT} from "../src/DayNightNFT.sol";

/**
 * @title MintDayNightNft
 * @author Abdelbasset10
 * @notice Mints a new token on the most recently deployed {DayNightNFT} for the current chain.
 * @dev Uses `DevOpsTools` to find the latest deployment in `broadcast/`, which requires read
 *      access to `./broadcast` in `fs_permissions`.
 *      Usage: `forge script script/Interactions.s.sol:MintDayNightNft --rpc-url <rpc> --broadcast`
 */
contract MintDayNightNft is Script {
    /**
     * @notice Mints one token to the broadcasting account.
     * @param nft The {DayNightNFT} contract to mint from.
     */
    function minNewNft(DayNightNFT nft) public {
        vm.startBroadcast();
        nft.minNFT();
        vm.stopBroadcast();
    }

    /// @notice Looks up the latest {DayNightNFT} deployment and mints a token on it.
    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "DayNightNFT",
            block.chainid
        );
        DayNightNFT nft = DayNightNFT(mostRecentlyDeployed);
        minNewNft(nft);
    }
}


/**
 * @title FliptMoodNFT
 * @author Abdelbasset10
 * @notice Flips the phase of a token on the most recently deployed {DayNightNFT} for the current chain.
 * @dev The broadcasting account must own the token or be approved for it.
 *      Usage: `forge script script/Interactions.s.sol:FliptMoodNFT --sig "run(uint256)" <tokenId> --rpc-url <rpc> --broadcast`
 */
contract FliptMoodNFT is Script {
    /**
     * @notice Flips the given token between DAY and NIGHT.
     * @param nft The {DayNightNFT} contract that holds the token.
     * @param tokenId The ID of the token to flip.
     */
    function flipMood(DayNightNFT nft, uint256 tokenId) public{
        vm.startBroadcast();
        nft.flipPhase(tokenId);
        vm.stopBroadcast();
    }

    /**
     * @notice Looks up the latest {DayNightNFT} deployment and flips the given token.
     * @param tokenId The ID of the token to flip, passed on the command line via `--sig`.
     */
    function run(uint256 tokenId) public {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("DayNightNFT",block.chainid);
        DayNightNFT nft = DayNightNFT(mostRecentDeployed);
        flipMood(nft, tokenId);

    }
}

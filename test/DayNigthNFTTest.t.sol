// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import {Test} from "forge-std/Test.sol";
import {DeployDayNightNft} from "../script/DeployDayNightNft.s.sol";
import {DayNightNFT} from "../src/DayNightNFT.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {
    IERC721Errors
} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

/**
 * @title DayNigthNFTTest
 * @author Abdelbasset10
 * @notice Unit tests for {DayNightNFT} and the {DeployDayNightNft} script.
 */
contract DayNigthNFTTest is Test {
    DayNightNFT nft;
    DeployDayNightNft deployer;

    address user = makeAddr("user");
    address user2 = makeAddr("user2");

    function setUp() public {
        deployer = new DeployDayNightNft();
        nft = deployer.run();
    }

    /**
     * @dev Builds the exact token URI the contract should return, independently of the contract's
     *      stored images (the image is rebuilt from the SVG files in `images/`).
     * @param tokenId The token ID used in the `name` field.
     * @param phase The phase used to pick the attribute value and the image.
     * @return The expected `data:application/json;base64,...` token URI.
     */
    function _expectedTokenURI(
        uint256 tokenId,
        DayNightNFT.Phase phase
    ) internal view returns (string memory) {
        bool isDay = phase == DayNightNFT.Phase.DAY;
        string memory imageURI = deployer.svgToImageURI(
            vm.readFile(isDay ? "./images/sun.svg" : "./images/moon.svg")
        );

        bytes memory metadata = abi.encodePacked(
            '{"name":"',
            nft.name(),
            " #",
            Strings.toString(tokenId),
            '",',
            '"description":"An NFT that flips between day and night.",',
            '"attributes":[{"trait_type":"phase","value":"',
            isDay ? "DAY" : "NIGHT",
            '"}],',
            '"image":"',
            imageURI,
            '"}'
        );

        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(metadata)
            );
    }

    function test_mintNewToken() public {
        vm.prank(user);
        nft.minNFT();
        assertEq(uint256(nft.getTokenMood(0)), uint256(DayNightNFT.Phase.DAY));
    }

    function test_tokenURI() public {
        vm.prank(user);
        nft.minNFT();

        assertEq(nft.tokenURI(0), _expectedTokenURI(0, DayNightNFT.Phase.DAY));
    }

    function test_flipPhase() public {
        vm.prank(user);
        nft.minNFT();
        string memory uriBefore = nft.tokenURI(0);

        vm.prank(user);
        nft.flipPhase(0);

        assertNotEq(nft.tokenURI(0), uriBefore);
        assertEq(
            nft.tokenURI(0),
            _expectedTokenURI(0, DayNightNFT.Phase.NIGHT)
        );
    }

    function test_flipPhaseTwice() public {
        vm.prank(user);
        nft.minNFT();
        vm.prank(user);
        nft.flipPhase(0);
        vm.prank(user);
        nft.flipPhase(0);

        assertEq(nft.tokenURI(0), _expectedTokenURI(0, DayNightNFT.Phase.DAY));
    }

    function test_notOwnerCantFlip() public {
        vm.prank(user);
        nft.minNFT();
        vm.prank(user2);
        vm.expectRevert(DayNightNFT.DayNightNFT__NotOwnerOrApproved.selector);
        nft.flipPhase(0);
    }

    function test_approvedAddressCanFlip() public {
        vm.prank(user);
        nft.minNFT();
        vm.prank(user);
        nft.approve(user2, 0);
        vm.prank(user2);
        nft.flipPhase(0);

        assertEq(
            nft.tokenURI(0),
            _expectedTokenURI(0, DayNightNFT.Phase.NIGHT)
        );
    }

    function test_flipNonExistingTokenReverts() public {
        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                0
            )
        );
        nft.flipPhase(0);
    }

    function test_SVGToURIWorks() public view {
        string memory svg = '<svg xmlns="http://www.w3.org/2000/svg"></svg>';
        string memory results = deployer.svgToImageURI(svg);
        string
            memory expectedResults = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjwvc3ZnPg==";

        assertEq(results, expectedResults);
    }
}

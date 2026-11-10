// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import {Script} from "forge-std/Script.sol";
import {DayNightNFT} from "../src/DayNightNFT.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title DeployDayNightNft
 * @author Abdelbasset10
 * @notice Deploys {DayNightNFT} using the sun and moon SVGs from the `images/` folder.
 * @dev Requires read access to `./images` in `fs_permissions` (see `foundry.toml`).
 */
contract DeployDayNightNft is Script {
    /**
     * @notice Reads both SVG files, converts them to image data URIs and deploys the NFT contract.
     * @return The deployed {DayNightNFT} instance.
     */
    function run() external returns (DayNightNFT) {
        string memory sunSvg = vm.readFile("./images/sun.svg");
        string memory moonSvg = vm.readFile("./images/moon.svg");

        vm.startBroadcast();
        DayNightNFT nft = new DayNightNFT(svgToImageURI(sunSvg),svgToImageURI(moonSvg));
        vm.stopBroadcast();
        return nft;
    }

    /**
     * @notice Converts raw SVG markup into a Base64-encoded image data URI.
     * @param svg The raw SVG markup, e.g. `<svg xmlns="http://www.w3.org/2000/svg"></svg>`.
     * @return The data URI `data:image/svg+xml;base64,<base64(svg)>`.
     */
    function svgToImageURI(
        string memory svg
    ) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(svg));
        return string.concat(baseURL, svgBase64Encoded);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title DayNightNFT
 * @author Abdelbasset10
 * @notice A fully on-chain ERC721 collection whose tokens switch between a sun (DAY) and a moon (NIGHT).
 * @dev Token metadata and images are stored and assembled entirely on-chain. `tokenURI` returns a
 *      Base64-encoded JSON data URI whose `image` field is one of two SVG data URIs supplied at deployment.
 */
contract DayNightNFT is ERC721 {
    /// @notice Thrown when the caller is neither the owner of the token nor approved to manage it.
    error DayNightNFT__NotOwnerOrApproved();

    /**
     * @notice Emitted when a new token is minted.
     * @param user The address that minted and received the token.
     * @param tokenId The ID of the newly minted token.
     */
    event DayNightNFT__MintedNewToken(
        address indexed user,
        uint256 indexed tokenId
    );

    /// @notice The two visual states a token can be in.
    enum Phase {
        DAY,
        NIGHT
    }

    /// @notice The ERC721 collection name.
    string public constant TOKEN_NAME = "Day Night";
    /// @notice The ERC721 collection symbol.
    string public constant TOKEN_SYMBOL = "DN";
    /// @notice The ID that will be assigned to the next minted token (equals the total number minted).
    uint256 public s_counter;
    /// @dev Current phase of each token. Defaults to `Phase.DAY` (0).
    mapping(uint256 tokenId => Phase mood) s_tokenToMood;

    /// @notice SVG image data URI shown while a token is in the DAY phase.
    string public s_sunSVG;
    /// @notice SVG image data URI shown while a token is in the NIGHT phase.
    string public s_moonSVG;

    /**
     * @param _sunSVG Image data URI for the DAY phase (e.g. `data:image/svg+xml;base64,...`).
     * @param _moonSVG Image data URI for the NIGHT phase (e.g. `data:image/svg+xml;base64,...`).
     */
    constructor(
        string memory _sunSVG,
        string memory _moonSVG
    ) ERC721(TOKEN_NAME, TOKEN_SYMBOL) {
        s_sunSVG = _sunSVG;
        s_moonSVG = _moonSVG;
        s_counter = 0;
    }

    /**
     * @notice Mints the next token to the caller. New tokens start in the DAY phase.
     * @dev Uses `_safeMint`, so contract callers must implement `IERC721Receiver`.
     *      Emits {DayNightNFT__MintedNewToken}.
     */
    function minNFT() public {
        s_tokenToMood[s_counter] = Phase.DAY;
        emit DayNightNFT__MintedNewToken(msg.sender, s_counter);
        _safeMint(msg.sender, s_counter);
        s_counter++;
    }

    /**
     * @notice Toggles a token between the DAY and NIGHT phases.
     * @dev Callable only by the token owner, an address approved for the token, or an operator
     *      approved for all of the owner's tokens.
     *      Reverts with `ERC721NonexistentToken(tokenId)` if the token does not exist, and with
     *      {DayNightNFT__NotOwnerOrApproved} if the caller is not authorized.
     * @param tokenId The ID of the token to flip.
     */
    function flipPhase(uint256 tokenId) public {
        address owner = _requireOwned(tokenId);
        if (!_isAuthorized(owner, msg.sender, tokenId)) {
            revert DayNightNFT__NotOwnerOrApproved();
        }
        if (s_tokenToMood[tokenId] == Phase.DAY) {
            s_tokenToMood[tokenId] = Phase.NIGHT;
        } else {
            s_tokenToMood[tokenId] = Phase.DAY  ;
        }
    }

    /**
     * @dev Prefix prepended to the Base64-encoded JSON metadata in {tokenURI}.
     * @return The JSON data URI prefix `data:application/json;base64,`.
     */
    function _baseURI() override pure internal  returns(string memory) {
        return "data:application/json;base64,";
    }

    /**
     * @notice Returns the fully on-chain metadata for a token.
     * @dev Builds a JSON object with `name`, `description`, `attributes` (the current phase) and
     *      `image` (the SVG data URI for the current phase), Base64-encodes it and prepends {_baseURI}.
     *      Reverts with `ERC721NonexistentToken(tokenId)` if the token does not exist.
     * @param tokenId The ID of the token to query.
     * @return A `data:application/json;base64,...` URI containing the token metadata.
     */
    function tokenURI(uint256 tokenId) override view public returns(string memory) {
        _requireOwned(tokenId);

        bool isDay = s_tokenToMood[tokenId] == Phase.DAY;
        string memory imageURI = isDay ? s_sunSVG : s_moonSVG;
        string memory phase = isDay ? "DAY" : "NIGHT";

        bytes memory metadata = abi.encodePacked(
            '{"name":"', name(), " #", Strings.toString(tokenId), '",',
            '"description":"An NFT that flips between day and night.",',
            '"attributes":[{"trait_type":"phase","value":"', phase, '"}],',
            '"image":"', imageURI, '"}'
        );

        return string.concat(_baseURI(), Base64.encode(metadata));
    }

    /**
     * @notice Returns the current phase of a token.
     * @dev Does not check that the token exists; non-existent tokens return `Phase.DAY`.
     * @param tokenId The ID of the token to query.
     * @return The token's current {Phase}.
     */
    function getTokenMood(uint256 tokenId) public view returns(Phase){
        return s_tokenToMood[tokenId];
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract CryptoWeeds is ERC721URIStorage, ERC721Enumerable, Ownable {
    using SafeMath for uint256;

    string public baseURI = "https://cryptoweeds.mypinata.cloud/ipfs/QmXo9bXjwSmkdBDCmAGtWxo1GAoC6EkDypjtf5tN16JZSp/";
    uint256 public startingIndex = 1;
    uint256 public cap;
    uint256 public basePrice = 1e16;
    uint256 public vanityTokenCount = 0;

    address marketing = 0x36A72afB5629c8A91Bc8567e5847326f6be3A302;
    address strategic = 0xFF5Fc803eF787d5D0719F3877B2542Cd2eA9B472;
    address team = 0xaAe2e0B59AE59a73Ba105dAE16A7603637d3D556;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _cap
    ) ERC721(name, symbol) {
        cap = _cap;
    }

    function setBasePrice(uint256 _basePrice) public onlyOwner {
        basePrice = _basePrice;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        uint256 marketingShare = balance.div(2);
        uint256 strategicShare = balance.sub(marketingShare).div(2);
        uint256 teamShare = balance.sub(strategicShare).sub(marketingShare);

        payable(marketing).transfer(marketingShare);
        payable(strategic).transfer(strategicShare);
        payable(team).transfer(teamShare);
    }

    function bookWeeds(uint256 _count) public onlyOwner {
        uint256 supply = totalSupply();
        uint256 i;
        for (i = 0; i < _count; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function bookVanityWeeds(uint256 _count) public onlyOwner {
        for (uint256 i = 1; i <= _count; i++) {
            _safeMint(msg.sender, cap + vanityTokenCount + i);
        }
        vanityTokenCount += _count;
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function calculatePrice() public view returns (uint256) {
        uint256 price;
        if (totalSupply() < 256) {
            price = 50 * basePrice;
        } else if (totalSupply() >= 256 && totalSupply() < 512) {
            price = 100 * basePrice;
        } else if (totalSupply() >= 512 && totalSupply() < 1024) {
            price = 150 * basePrice;
        } else if (totalSupply() >= 1024 && totalSupply() < 1536) {
            price = 200 * basePrice;
        } else {
            price = 300 * basePrice;
        }
        return price;
    }

    function mint(uint256 amount) public payable {
        require(totalSupply().add(amount) <= cap, "Mint over the max nft amount");
        require(calculatePrice().mul(amount) <= msg.value, "Value sent less than needed");

        for (uint256 i = 0; i < amount; i++) {
            uint256 index = totalSupply();
            _safeMint(msg.sender, index);
        }
    }
}

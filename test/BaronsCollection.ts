import { expect } from "chai";
import { ethers } from "hardhat";

let token: any;
let owner: any;
let user1: any;
let user2: any;
let administrator: any;
let administrator2: any;

before(async () => {

  [owner, user1, user2, administrator, administrator2] = await ethers.getSigners();

  const factoryToken = await ethers.getContractFactory("BaronsCollection");
  token = await factoryToken.deploy([administrator.address,administrator2.address]);
  await token.deployed();

});

describe("Support Interfaces Test", function () {
  const INTERFACE_IDS = {
    ERC165: "0x01ffc9a7",
    ERC721: "0x80ac58cd",
    ERC721Metadata: "0x5b5e139f",
    ERC721TokenReceiver: "0x150b7a02",
    ERC721Enumerable: "0x780e9d63",
    AccessControl: "0x7965db0b",
    ERC2981: "0x2a55205a",
  };

  it("ERC165", async function () {
    expect(await token.supportsInterface(INTERFACE_IDS.ERC165)).to.be.true;
  });
  it("ERC721", async function () {
    expect(await token.supportsInterface(INTERFACE_IDS.ERC721)).to.be.true;
  });
  it("ERC721Metadata", async function () {
    expect(await token.supportsInterface(INTERFACE_IDS.ERC721Metadata)).to
      .be.true;
  });
  it("AccessControl", async function () {
    expect(await token.supportsInterface(INTERFACE_IDS.AccessControl)).to.be
      .true;
  });
  it("ERC2981", async function () {
    expect(await token.supportsInterface(INTERFACE_IDS.ERC2981)).to.be.true;
  });
});

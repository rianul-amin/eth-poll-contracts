import { ethers } from "hardhat";

async function main() {
  const PollContractFactory = await ethers.getContractFactory("PollContract");
  const pollContract = await PollContractFactory.deploy();

  console.log("poll contract deployed to:", pollContract.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

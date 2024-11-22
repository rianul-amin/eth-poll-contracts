import { expect } from "chai";
import { ethers } from "hardhat";
import { PollContract } from "../typechain-types";
import { BigNumberish } from "ethers";

interface Poll {
  title: string;
  description: string;
  options: string[];
  votes: BigNumberish[];
  duration: BigNumberish;
  endTime: BigNumberish;
  isClosed: boolean;
}

describe("PollContract", function () {
  let pollContract: PollContract;
  let admin: any;
  let addr1: any;
  let addr2: any;

  beforeEach(async function () {
    const PollContractFactory = await ethers.getContractFactory("PollContract");
    [admin, addr1, addr2] = await ethers.getSigners();
    pollContract = await PollContractFactory.deploy();
  });

  describe("Poll creation", function () {
    it("Should create a poll", async function () {
      const title = "Poll Title";
      const description = "Poll Description";
      const options = ["Option 1", "Option 2"];
      const duration = 3600;

      await expect(
        pollContract.createPoll(title, description, options, duration)
      )
        .to.emit(pollContract, "PollCreated")
        .withArgs(0, title, duration);

      const pollTuple = await pollContract.polls(0);

      const [
        titleFromContract,
        descriptionFromContract,
        durationFromContract,
        endTimeFromContract,
        isClosedFromContract,
      ] = pollTuple;

      const pollData: Poll = {
        title: titleFromContract,
        description: descriptionFromContract,
        options: options,
        votes: [0, 0],
        duration: durationFromContract,
        endTime: endTimeFromContract,
        isClosed: isClosedFromContract,
      };

      expect(pollData.title).to.equal(title);
      expect(pollData.description).to.equal(description);
      expect(pollData.options).to.deep.equal(options);
      expect(pollData.duration).to.equal(duration);
      expect(pollData.isClosed).to.be.false;
    });
  });

  describe("Voting", function () {
    it("Should allow a user to vote", async function () {
      const title = "Poll Title";
      const description = "Poll Description";
      const options = ["Option 1", "Option 2"];
      const duration = 3600;

      await pollContract.createPoll(title, description, options, duration);

      await expect(pollContract.connect(addr1).vote(0, 0))
        .to.emit(pollContract, "Voted")
        .withArgs(0, addr1.address, 0);

      const pollTuple = await pollContract.polls(0);

      const [
        titleFromContract,
        descriptionFromContract,
        durationFromContract,
        endTimeFromContract,
        isClosedFromContract,
      ] = pollTuple;

      const pollData: Poll = {
        title: titleFromContract,
        description: descriptionFromContract,
        options: options,
        votes: [1, 0],
        duration: durationFromContract,
        endTime: endTimeFromContract,
        isClosed: isClosedFromContract,
      };

      expect(pollData.votes[0]).to.equal(1);
      expect(pollData.votes[1]).to.equal(0);

      expect(pollData.title).to.equal(title);
      expect(pollData.description).to.equal(description);
      expect(pollData.options).to.deep.equal(options);
      expect(pollData.duration).to.equal(duration);
      expect(pollData.isClosed).to.be.false;
    });
  });

  describe("User Voting History Details", function () {
    it("Should return correct voting history details", async function () {
      const polls = [
        { title: "Poll 1", description: "Description 1", options: ["A", "B"], duration: 3600 },
        { title: "Poll 2", description: "Description 2", options: ["X", "Y"], duration: 3600 },
        { title: "Poll 3", description: "Description 3", options: ["M", "N"], duration: 3600 },
      ];
  
      for (const poll of polls) {
        await pollContract.createPoll(poll.title, poll.description, poll.options, poll.duration);
      }
  
      await pollContract.connect(addr1).vote(0, 1); 
      await pollContract.connect(addr1).vote(2, 0); 
  
      const [pollIds, votedOptions] = await pollContract.getUserVotingHistory(addr1.address);
  
      expect(pollIds).to.deep.equal([0, 2]); 
      expect(votedOptions).to.deep.equal(["B", "M"]); 
    });
  });
  
});

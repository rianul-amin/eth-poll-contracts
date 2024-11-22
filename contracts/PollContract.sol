// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollContract {

    struct Poll {
        string title;
        string description;
        string[] options;
        uint256[] votes;
        uint256 duration; 
        uint256 endTime;
        bool isClosed;
    }

    address public admin;  
    mapping(uint256 => Poll) public polls; 
    mapping(address => mapping(uint256 => bool)) public hasVoted; 
    mapping(address => mapping(uint256 => uint256)) public userVotes; 

    uint256 public pollCount;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyActivePoll(uint256 pollId) {
        require(!polls[pollId].isClosed, "Poll is already closed");
        _;
    }

    event PollCreated(uint256 pollId, string title, uint256 duration);
    event Voted(uint256 pollId, address voter, uint256 option);
    event PollClosed(uint256 pollId);

    constructor() {
        admin = msg.sender;  
    }

    function createPoll( string memory _title, string memory _description, string[] memory _options, uint256 _duration ) external onlyAdmin {
        require(_options.length > 1, "There must be at least two options");
        require(_duration > 60, "Duration should be at least 1 minute");

        uint256 pollId = pollCount++;  
        uint256[] memory initialVotes = new uint256[](_options.length);

        polls[pollId] = Poll({
            title: _title,
            description: _description,
            options: _options,
            votes: initialVotes,
            duration: _duration,
            endTime: block.timestamp + _duration,
            isClosed: false
        });

        emit PollCreated(pollId, _title, _duration);
    }

    function vote(uint256 pollId, uint256 optionIndex) external onlyActivePoll(pollId) {
        require(optionIndex < polls[pollId].options.length, "Invalid option");
        require(!hasVoted[msg.sender][pollId], "You have already voted");

        hasVoted[msg.sender][pollId] = true;
        userVotes[msg.sender][pollId] = optionIndex; 

        polls[pollId].votes[optionIndex]++;

        emit Voted(pollId, msg.sender, optionIndex);
    }

    function closePoll(uint256 pollId) external onlyAdmin {
        require(!polls[pollId].isClosed, "Poll is already closed");

        polls[pollId].isClosed = true;
        emit PollClosed(pollId);
    }

    function getPollInfo(uint256 pollId) external view returns ( string memory title, string memory description, string[] memory options, uint256[] memory votes, uint256 duration, uint256 endTime, bool isClosed, string memory status, uint256 remainingTime ) {
        Poll storage poll = polls[pollId];
        bool pollClosed = poll.isClosed || block.timestamp >= poll.endTime;
        string memory pollStatus = pollClosed ? "Closed" : "Open";
        uint256 remainingTimeForPoll = pollClosed ? 0 : (poll.endTime > block.timestamp ? poll.endTime - block.timestamp : 0);

        return ( 
            poll.title,
            poll.description,
            poll.options,
            poll.votes,
            poll.duration,
            poll.endTime,
            pollClosed,
            pollStatus,
            remainingTimeForPoll
        );
    }

    function getUserVotingHistory(address user) external view returns ( uint256[] memory pollIds, string[] memory votedOptions ) {
        uint256 userPollCount = 0;

        for (uint256 i = 0; i < pollCount; i++) {
            if (hasVoted[user][i]) {
                userPollCount++;
            }
        }

        uint256[] memory _pollIds = new uint256[](userPollCount);
        string[] memory _votedOptions = new string[](userPollCount);

        uint256 index = 0;

        for (uint256 i = 0; i < pollCount; i++) {
            if (hasVoted[user][i]) {
                _pollIds[index] = i;
                _votedOptions[index] = polls[i].options[userVotes[user][i]];
                index++;
            }
        }

        return (_pollIds, _votedOptions);
    }
}

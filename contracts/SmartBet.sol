// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SmartBet is Ownable {
    struct User {
        bool isRegistered;
        string username;
    }
    struct Bet {
        address bettor;
        uint256 matchId;
        uint256 predictedHomeScore;
        uint256 predictedAwayScore;
        uint256 amount;
    }
    struct Match {
        uint256 id;
        uint256 realHomeScore;
        uint256 realAwayScore;
        bool isFinished;
        bool exists;
    }

    mapping(address => User) public users;
    mapping(uint256 => Bet[]) public betsByMatch;
    mapping(uint256 => Match) public matches;
    mapping(address => mapping(uint256 => bool)) public userHasBetOnMatch;

    event UserRegistered(address user, string username);
    event BetPlaced(
        address bettor,
        uint256 matchId,
        uint256 predictedHomeScore,
        uint256 predictedAwayScore,
        uint256 amount
    );
    event WinnersDetermined(uint256 matchId, uint256 winnersCount);
    event MatchAdded(uint256 matchId);
    event MatchUpdated(
        uint256 matchId,
        uint256 realHomeScore,
        uint256 realAwayScore
    );

    constructor() Ownable(msg.sender) {}

    function registerUser(string memory username) public {
        require(!users[msg.sender].isRegistered, "User already registered.");
        users[msg.sender] = User(true, username);
        emit UserRegistered(msg.sender, username);
    }

    function placeBet(
        uint256 matchId,
        uint256 predictedHomeScore,
        uint256 predictedAwayScore
    ) public payable {
        require(users[msg.sender].isRegistered, "User not registered.");
        require(msg.value > 0, "Betting amount must be greater than 0");
        require(matches[matchId].exists, "Match does not exist.");
        require(!matches[matchId].isFinished, "Match is already finished.");
        require(
            !userHasBetOnMatch[msg.sender][matchId],
            "User has already placed a bet on this match."
        );

        betsByMatch[matchId].push(
            Bet(
                msg.sender,
                matchId,
                predictedHomeScore,
                predictedAwayScore,
                msg.value
            )
        );
        userHasBetOnMatch[msg.sender][matchId] = true;

        emit BetPlaced(
            msg.sender,
            matchId,
            predictedHomeScore,
            predictedAwayScore,
            msg.value
        );
    }

    function addMatch(uint256 matchId) public onlyOwner {
        require(!matches[matchId].exists, "Match already exists.");
        matches[matchId] = Match(matchId, 0, 0, false, true);
        emit MatchAdded(matchId);
    }

    function updateMatch(
        uint256 matchId,
        uint256 realHomeScore,
        uint256 realAwayScore
    ) public onlyOwner {
        require(matches[matchId].exists, "Match does not exist.");
        require(!matches[matchId].isFinished, "Match is already finished.");
        matches[matchId].realHomeScore = realHomeScore;
        matches[matchId].realAwayScore = realAwayScore;
        matches[matchId].isFinished = true;
        emit MatchUpdated(matchId, realHomeScore, realAwayScore);
        determineWinners(matchId);
    }

    function determineWinners(uint256 matchId) internal {
        uint256 totalPrize = 0;
        uint256 winnersCount = 0;
        for (uint256 i = 0; i < betsByMatch[matchId].length; i++) {
            Bet memory bet = betsByMatch[matchId][i];
            if (
                bet.predictedHomeScore == matches[matchId].realHomeScore &&
                bet.predictedAwayScore == matches[matchId].realAwayScore
            ) {
                winnersCount++;
                totalPrize += bet.amount;
            }
        }
        distributeWinnings(matchId, winnersCount, totalPrize);
        emit WinnersDetermined(matchId, winnersCount);
    }

    function distributeWinnings(
        uint256 matchId,
        uint256 winnersCount,
        uint256 totalPrize
    ) internal {
        if (winnersCount > 0) {
            uint256 prizePerWinner = totalPrize / winnersCount;
            for (uint256 i = 0; i < betsByMatch[matchId].length; i++) {
                Bet memory bet = betsByMatch[matchId][i];
                if (
                    bet.predictedHomeScore == matches[matchId].realHomeScore &&
                    bet.predictedAwayScore == matches[matchId].realAwayScore
                ) {
                    payable(bet.bettor).transfer(prizePerWinner);
                }
            }
        }
    }
}

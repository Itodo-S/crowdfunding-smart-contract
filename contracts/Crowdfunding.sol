// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// DEPENDENCIES
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Crowdfunding is Ownable, ReentrancyGuard {
    constructor() Ownable(msg.sender) {}

// CAMPAIGN STRUCTURE
    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint256 goal;
        uint256 deadline;
        uint256 amountRaised;
        bool ended;
    }

    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;

    event CampaignCreated(
        uint256 indexed campaignId,
        string title,
        string description,
        address benefactor,
        uint256 goal,
        uint256 deadline
    );
    event DonationReceived(
        uint256 indexed campaignId,
        address indexed donor,
        uint256 amount
    );
    event CampaignEnded(
        uint256 indexed campaignId,
        address benefactor,
        uint256 amountRaised
    );

    modifier onlyActiveCampaign(uint256 _campaignId) {
        require(
            block.timestamp < campaigns[_campaignId].deadline,
            "Campaign has ended."
        );
        require(
            !campaigns[_campaignId].ended,
            "Campaign has already been ended."
        );
        _;
    }

    modifier onlyBenefactor(uint256 _campaignId) {
        require(
            msg.sender == campaigns[_campaignId].benefactor,
            "Only the benefactor can call this function."
        );
        _;
    }

    // FUNC TO CREATE A NEW CAMPAIGN
    function createCampaign(
        string calldata _title,
        string calldata _description,
        address payable _benefactor,
        uint256 _goal,
        uint256 _duration
    ) external {
        require(_goal > 0, "Fundraising goal must be greater than zero.");

        campaignCount++;
        campaigns[campaignCount] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: block.timestamp + _duration,
            amountRaised: 0,
            ended: false
        });

        emit CampaignCreated(
            campaignCount,
            _title,
            _description,
            _benefactor,
            _goal,
            block.timestamp + _duration
        );
    }

    // FUNC TO DONATE TO A CAMPAIGN
    function donateToCampaign(uint256 _campaignId)
        external
        payable
        onlyActiveCampaign(_campaignId)
    {
        Campaign storage campaign = campaigns[_campaignId];
        campaign.amountRaised += msg.value;

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    // FUNC TO END THE CAMPAIGN AND TRANSFER FUNDS TO THE BENEFACTOR
    function endCampaign(uint256 _campaignId)
        external
        nonReentrant
        onlyActiveCampaign(_campaignId)
        onlyBenefactor(_campaignId)
    {
        Campaign storage campaign = campaigns[_campaignId];
        require(
            block.timestamp >= campaign.deadline,
            "Campaign deadline has not yet passed."
        );

        campaign.ended = true;
        campaign.benefactor.transfer(campaign.amountRaised);

        emit CampaignEnded(
            _campaignId,
            campaign.benefactor,
            campaign.amountRaised
        );
    }

    // FUNC FOR THE CONTRACT OWNER TO WITHDRAW LEFTOVER FUNDS
    function withdrawLeftoverFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}

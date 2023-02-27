pragma solidity ^0.8.13;

interface IBeanStalk {
    function depositBeans(uint256) external;

    function emergencyCommit(uint32 bip) external;

    function deposit(address token, uint256 amount) external;

    struct FacetCut {
        address facetAddress;
        uint8 action;
        bytes4[] functionSelectors;
    }

    function propose(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata,
        uint8 _pauseOrUnpause
    ) external;
}

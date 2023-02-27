// contract pool{
//      /**
//    * @dev Allows smartcontracts to access the liquidity of the pool within one transaction,
//    * as long as the amount taken plus a fee is returned.
//    * IMPORTANT There are security concerns for developers of flashloan receiver contracts that must be kept into consideration.
//    * For further details please visit https://developers.aave.com
//    * @param receiverAddress The address of the contract receiving the funds, implementing the IFlashLoanReceiver interface
//    * @param assets The addresses of the assets being flash-borrowed
//    * @param amounts The amounts amounts being flash-borrowed
//    * @param modes Types of the debt to open if the flash loan is not returned:
//    *   0 -> Don't open any debt, just revert if funds can't be transferred from the receiver
//    *   1 -> Open debt at stable rate for the value of the amount flash-borrowed to the `onBehalfOf` address
//    *   2 -> Open debt at variable rate for the value of the amount flash-borrowed to the `onBehalfOf` address
//    * @param onBehalfOf The address  that will receive the debt in the case of using on `modes` 1 or 2
//    * @param params Variadic packed params to pass to the receiver as extra information
//    * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
//    *   0 if the action is executed directly by the user, without any middle-man
//    **/
//   function flashLoan(
//     address receiverAddress,
//     address[] calldata assets,
//     uint256[] calldata amounts,
//     uint256[] calldata modes,
//     address onBehalfOf,
//     bytes calldata params,
//     uint16 referralCode
//   ) external override whenNotPaused {
//     FlashLoanLocalVars memory vars;

//     ValidationLogic.validateFlashloan(assets, amounts);

//     address[] memory aTokenAddresses = new address[](assets.length);
//     uint256[] memory premiums = new uint256[](assets.length);

//     vars.receiver = IFlashLoanReceiver(receiverAddress);

//     for (vars.i = 0; vars.i < assets.length; vars.i++) {
//       aTokenAddresses[vars.i] = _reserves[assets[vars.i]].aTokenAddress;

//       premiums[vars.i] = amounts[vars.i].mul(_flashLoanPremiumTotal).div(10000);

//       IAToken(aTokenAddresses[vars.i]).transferUnderlyingTo(receiverAddress, amounts[vars.i]);
//     }

//     require(
//       vars.receiver.executeOperation(assets, amounts, premiums, msg.sender, params),
//       Errors.LP_INVALID_FLASH_LOAN_EXECUTOR_RETURN
//     );

//     for (vars.i = 0; vars.i < assets.length; vars.i++) {
//       vars.currentAsset = assets[vars.i];
//       vars.currentAmount = amounts[vars.i];
//       vars.currentPremium = premiums[vars.i];
//       vars.currentATokenAddress = aTokenAddresses[vars.i];
//       vars.currentAmountPlusPremium = vars.currentAmount.add(vars.currentPremium);

//       if (DataTypes.InterestRateMode(modes[vars.i]) == DataTypes.InterestRateMode.NONE) {
//         _reserves[vars.currentAsset].updateState();
//         _reserves[vars.currentAsset].cumulateToLiquidityIndex(
//           IERC20(vars.currentATokenAddress).totalSupply(),
//           vars.currentPremium
//         );
//         _reserves[vars.currentAsset].updateInterestRates(
//           vars.currentAsset,
//           vars.currentATokenAddress,
//           vars.currentAmountPlusPremium,
//           0
//         );

//         IERC20(vars.currentAsset).safeTransferFrom(
//           receiverAddress,
//           vars.currentATokenAddress,
//           vars.currentAmountPlusPremium
//         );
//       } else {
//         // If the user chose to not return the funds, the system checks if there is enough collateral and
//         // eventually opens a debt position
//         _executeBorrow(
//           ExecuteBorrowParams(
//             vars.currentAsset,
//             msg.sender,
//             onBehalfOf,
//             vars.currentAmount,
//             modes[vars.i],
//             vars.currentATokenAddress,
//             referralCode,
//             false
//           )
//         );
//       }
//       emit FlashLoan(
//         receiverAddress,
//         msg.sender,
//         vars.currentAsset,
//         vars.currentAmount,
//         vars.currentPremium,
//         referralCode
//       );
//     }
//   }
// }
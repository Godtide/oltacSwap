// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.3;

pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./oltac.sol";

contract OltSwap {
  
    ISwapRouter public immutable swapRouter;

    // This example swaps olt/WETH9 for single path swaps 

    address public constant olt = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    /// @notice swapExactInputSingle swaps a fixed amount of olt for a maximum possible amount of WETH9
    /// using the olt/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its olt for this function to succeed.
    /// @param amountIn The exact amount of olt that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
        // msg.sender must approve this contract

        // Transfer the specified amount of olt to this contract.
        TransferHelper.safeTransferFrom(olt, msg.sender, address(this), amountIn);

        // Approve the router to spend olt.
        TransferHelper.safeApprove(olt, address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: olt,
                tokenOut: WETH9,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }

    /// @notice swapExactOutputSingle swaps a minimum possible amount of olt for a fixed amount of WETH.
    /// @dev The calling address must approve this contract to spend its olt for this function to succeed. As the amount of input olt is variable,
    /// the calling address will need to approve for a slightly higher amount, anticipating some variance.
    /// @param amountOut The exact amount of WETH9 to receive from the swap.
    /// @param amountInMaximum The amount of olt we are willing to spend to receive the specified amount of WETH9.
    /// @return amountIn The amount of olt actually spent in the swap.
    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {
        // Transfer the specified amount of olt to this contract.
        TransferHelper.safeTransferFrom(olt, msg.sender, address(this), amountInMaximum);

        // Approve the router to spend the specifed `amountInMaximum` of olt.
        // In production, you should choose the maximum amount to spend based on oracles or other data sources to acheive a better swap.
        TransferHelper.safeApprove(olt, address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: olt,
                tokenOut: WETH9,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
        amountIn = swapRouter.exactOutputSingle(params);

        // For exact output swaps, the amountInMaximum may not have all been spent.
        // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.
        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(olt, address(swapRouter), 0);
            TransferHelper.safeTransfer(olt, msg.sender, amountInMaximum - amountIn);
        }
    }
}
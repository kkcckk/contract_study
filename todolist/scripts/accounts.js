const hre = require("hardhat");

async function main() {
    const accounts = await hre.ethers.getSigners();

    for(const account of accounts) {
        console.log(account);
    }
}


main().catch(error=>{
    console.log(error);
    process.exitCode=1;
});
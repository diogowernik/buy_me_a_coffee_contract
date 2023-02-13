async function main() {
    const BuyCoffee = await hre.ethers.getContractFactory("BuyCoffee");
    const buycoffee = await BuyCoffee.deploy();
    await buycoffee.deployed();

    console.log("BuyMeACoffee contract address:", buycoffee.address);    
}

main().catch((error) => {
        console.error(error);
        process.exitCode = 1;
});


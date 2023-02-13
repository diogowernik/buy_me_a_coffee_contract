npm init -y
npm install --save-dev hardhat 
npx hardhat
npx hardhat test

npm install --save-dev dotenv

npx hardhat run scripts/deploy.js --network goerli
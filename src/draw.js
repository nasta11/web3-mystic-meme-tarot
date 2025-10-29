const fs = require("fs");
const path = require("path");

// 🔗 IPFS-хэш (временно можно оставить фейковый, позже заменим на настоящий)
const IPFS_BASE = "ipfs://QmExampleHash";

// 🎴 Колода (только пример — потом добавим все 21)
const cards = [
  { name: "The Meme", meaning: "Origin — chaos and creation" },
  { name: "The Rug", meaning: "Beware the pull of false promises in DeFi — a warning of scams and exits." },
  { name: "The Seed", meaning: "Potential taking root; plant your vision." },
  { name: "The Wallet", meaning: "Identity and access — protect your keys." },
  { name: "The Bridge", meaning: "Transition between worlds — connection, evolution." }
];

// 🌀 Функция задержки
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// 🜏 Призывание одной карты
async function summonOne() {
  console.clear();
  const messages = [
    "🜏 Summoning your card...",
    "🌙 Channeling Web3 energy...",
    "✨ The mists are parting..."
  ];
  for (const msg of messages) {
    process.stdout.write(msg);
    await sleep(900);
    process.stdout.write("\r" + " ".repeat(msg.length) + "\r");
  }

  const randomCard = cards[Math.floor(Math.random() * cards.length)];
  randomCard.image = `${IPFS_BASE}/${randomCard.name.replace(/\s+/g, "_")}.png`;

  console.log(`🔮 Your card: ${randomCard.name}`);
  console.log(`💫 Meaning: ${randomCard.meaning}`);
  console.log(`🖼️ Image: ${randomCard.image}\n`);

  fs.writeFileSync(
    "./metadata/output.json",
    JSON.stringify(randomCard, null, 2)
  );

  console.log("✨ Metadata exported to metadata/output.json");
  console.log("🖤 May your fate unfold in code.");
}

// 🗂️ Экспорт всей колоды
function exportAll() {
  const dir = "./metadata/all";
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

  cards.forEach((card, i) => {
    const fileSafeName = card.name.replace(/\s+/g, "_");
    const filename = path.join(dir, `${i + 1}-${fileSafeName}.json`);
    const metadata = {
      name: card.name,
      meaning: card.meaning,
      image: `${IPFS_BASE}/${fileSafeName}.png`,
      attributes: [
        { trait_type: "Card Type", value: "Tarot" },
        { trait_type: "Series", value: "Web3 Mystic Meme" }
      ]
    };
    fs.writeFileSync(filename, JSON.stringify(metadata, null, 2));
  });

  console.log(`🪄 Exported ${cards.length} cards with IPFS links to ${dir}/`);
  console.log("✨ Ready for NFT minting or IPFS upload.");
}

// ⚙️ Определяем режим запуска
if (process.argv.includes("--all")) {
  exportAll();
} else {
  summonOne();
}


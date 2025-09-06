# ⚡️ Gas Optimizer

[![Made with Hardhat](https://img.shields.io/badge/Made%20with-Hardhat-FF5733?style=for-the-badge&logo=ethereum)](https://hardhat.org/)
[![Tests passing](https://img.shields.io/badge/Tests-passing-brightgreen?style=for-the-badge&logo=mocha)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](./LICENSE)

> 💡 Пример проекта на Solidity с демонстрацией и сравнением gas usage между обычным и оптимизированным контрактом.

---

## 📦 Описание

Этот проект показывает:

- Разницу между `storage`, `memory`, `stack`, `calldata`
- Как можно оптимизировать контракт по потреблению газа
- Использование `hardhat-gas-reporter`
- Написание unit-тестов в Hardhat

---

## 🚀 Установка и запуск

```bash
git clone git@github.com:nasta11/gas-optimizer.git
cd gas-optimizer
npm install
npx hardhat test
```

---

## 📁 Структура

```
gas-optimizer/
├── contracts/            # Контракты GasDemo и GasOptimized
├── test/                 # Unit тесты для оптимизированного контракта
├── hardhat.config.js     # Конфигурация Hardhat + gas-reporter
└── README.md             # Документация
```

---

## 🧪 Unit-тесты

Проверяется:

- Возврат строки из `constant storage`
- Передача `calldata`
- Арифметика с использованием `unchecked`

---

## 📊 Сравнение газа

| Функция         | Обычный контракт | Оптимизированный |
|-----------------|------------------|------------------|
| useCalldata     |     XX gas       |     YY gas       |
| add             |     XX gas       |     YY gas       |

_Примерные значения можно посмотреть в `npx hardhat test` с `gas-reporter`._

---

## 🧠 Цель

Развить навыки написания эффективных и оптимизированных смарт-контрактов с покрытием тестами.

---

## 📜 Лицензия

Проект распространяется под лицензией [MIT](./LICENSE).

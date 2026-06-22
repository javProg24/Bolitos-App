# bolitos-backend

bolitos-backend/
│
├── functions/
│   ├── src/
│   │   ├── index.ts
│   │   │
│   │   ├── auth/
│   │   │   ├── assign-admin-role.ts
│   │   │   ├── disable-user.ts
│   │   │   └── validate-admin.ts
│   │   │
│   │   ├── products/
│   │   │   ├── create-product.ts
│   │   │   ├── update-product.ts
│   │   │   ├── update-stock.ts
│   │   │   └── disable-product.ts
│   │   │
│   │   ├── orders/
│   │   │   ├── create-order.ts
│   │   │   ├── accept-order.ts
│   │   │   ├── reject-order.ts
│   │   │   ├── cancel-order.ts
│   │   │   ├── update-order-status.ts
│   │   │   └── update-payment-status.ts
│   │   │
│   │   ├── shared/
│   │   │   ├── errors.ts
│   │   │   ├── permissions.ts
│   │   │   └── validators.ts
│   │   │
│   │   └── types/
│   │       ├── product.types.ts
│   │       ├── order.types.ts
│   │       └── user.types.ts
│   │
│   ├── package.json
│   └── tsconfig.json
│
├── tests/
│   ├── firestore/
│   │   ├── products.rules.test.ts
│   │   ├── orders.rules.test.ts
│   │   └── users.rules.test.ts
│   │
│   └── functions/
│
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
├── firebase.json
├── .firebaserc
├── .gitignore
├── package.json
└── README.md

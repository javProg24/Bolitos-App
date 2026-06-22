# bolitos-fronted_client

BOLITOS-CLIENT/
│
├── .claude/
├── .vscode/
│
├── assets/
│   ├── fonts/
│   ├── icons/
│   └── images/
│       ├── logo.png
│       ├── login-background.png
│       ├── splash.png
│       └── product-placeholder.png
│
├── node_modules/
│
├── scripts/
│
├── src/
│   │
│   ├── app/
│   │   ├── _layout.tsx
│   │   ├── index.tsx
│   │   ├── +not-found.tsx
│   │   │
│   │   ├── (auth)/
│   │   │   ├── _layout.tsx
│   │   │   ├── login.tsx
│   │   │   ├── register.tsx
│   │   │   └── forgot-password.tsx
│   │   │
│   │   ├── (tabs)/
│   │   │   ├── _layout.tsx
│   │   │   ├── index.tsx
│   │   │   ├── catalog.tsx
│   │   │   ├── cart.tsx
│   │   │   ├── orders.tsx
│   │   │   └── profile.tsx
│   │   │
│   │   ├── product/
│   │   │   └── [id].tsx
│   │   │
│   │   ├── order/
│   │   │   ├── confirm.tsx
│   │   │   └── [id].tsx
│   │   │
│   │   └── profile/
│   │       └── edit.tsx
│   │
│   ├── components/
│   │   ├── ui/
│   │   │   ├── AppButton.tsx
│   │   │   ├── AppInput.tsx
│   │   │   ├── AppHeader.tsx
│   │   │   ├── AppModal.tsx
│   │   │   ├── Loading.tsx
│   │   │   └── EmptyState.tsx
│   │   │
│   │   ├── products/
│   │   │   ├── ProductCard.tsx
│   │   │   ├── ProductList.tsx
│   │   │   └── QuantitySelector.tsx
│   │   │
│   │   ├── cart/
│   │   │   ├── CartItem.tsx
│   │   │   └── CartSummary.tsx
│   │   │
│   │   └── orders/
│   │       ├── OrderCard.tsx
│   │       └── OrderStatusBadge.tsx
│   │
│   ├── constants/
│   │   ├── colors.ts
│   │   ├── routes.ts
│   │   ├── roles.ts
│   │   ├── order-status.ts
│   │   └── app-config.ts
│   │
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   ├── useThemeColor.ts
│   │   ├── useColorScheme.ts
│   │   └── useDebounce.ts
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── services/
│   │   │   │   └── auth.service.ts
│   │   │   ├── types/
│   │   │   │   └── auth.types.ts
│   │   │   └── validations/
│   │   │       └── auth.schema.ts
│   │   │
│   │   ├── products/
│   │   │   ├── services/
│   │   │   │   └── product.service.ts
│   │   │   └── types/
│   │   │       └── product.types.ts
│   │   │
│   │   ├── cart/
│   │   │   ├── services/
│   │   │   │   └── cart.service.ts
│   │   │   └── types/
│   │   │       └── cart.types.ts
│   │   │
│   │   ├── orders/
│   │   │   ├── services/
│   │   │   │   └── order.service.ts
│   │   │   └── types/
│   │   │       └── order.types.ts
│   │   │
│   │   └── profile/
│   │       ├── services/
│   │       │   └── profile.service.ts
│   │       └── types/
│   │           └── profile.types.ts
│   │
│   ├── services/
│   │   ├── firebase/
│   │   │   ├── firebase.config.ts
│   │   │   ├── auth.firebase.ts
│   │   │   ├── firestore.firebase.ts
│   │   │   └── storage.firebase.ts
│   │   │
│   │   └── local-storage/
│   │       └── storage.service.ts
│   │
│   ├── store/
│   │   ├── auth.store.ts
│   │   ├── cart.store.ts
│   │   └── order.store.ts
│   │
│   ├── types/
│   │   ├── navigation.types.ts
│   │   └── common.types.ts
│   │
│   ├── utils/
│   │   ├── currency.ts
│   │   ├── date.ts
│   │   ├── errors.ts
│   │   └── validators.ts
│   │
│   ├── mocks/
│   │   ├── products.mock.ts
│   │   └── orders.mock.ts
│   │
│   └── global.css
│
├── .env
├── .env.example
├── .gitignore
├── AGENTS.md
├── app.json
├── CLAUDE.md
├── LICENSE
├── package.json
├── pnpm-lock.yaml
├── README.md
└── tsconfig.json
---
title: "Primeiro post"
description: "O pontapé inicial deste blog: como ele foi construído e por que ele é tão simples."
pubDate: 2026-11-07
---

Olá! Este é o primeiro post do blog.

## De onde veio a ideia

A ideia é simples: um lugar para escrever. Sem framework de interface, sem banco de
dados e sem JavaScript rodando no navegador — apenas Markdown virando HTML estático
no build, servido o mais rápido possível.

## Como este blog funciona

1. Escrevo um arquivo `.md` em `src/content/blog/` com título, descrição e data.
2. O Astro valida o frontmatter, gera o HTML estático e otimiza tudo.
3. A Vercel distribui os arquivos pela borda da rede.

## Um bloco de código, para testar

```js
const simples = (a, b) => a + b;
```

É isso. Menos ferramentas, mais texto.

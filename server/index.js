const express = require('express');
const axios = require('axios');
const app = express();

// 中间层 API 扣费逻辑
app.post('/api/generate', async (req, res) => {
    try {
        // 1. 验证用户余额
        const userBalance = await checkUserBalance(req.headers.authorization);
        if (userBalance <= 0) {
            return res.status(403).json({ error: '余额不足，请充值' });
        }

        // 2. 转发请求到 DeepSeek API
        const response = await axios.post('https://api.deepseek.com/chat/completions', req.body, {
            headers: {
                'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`,
                'Content-Type': 'application/json'
            }
        });

        // 3. 扣费
        await deductBalance(req.headers.authorization, response.data.usage.total_tokens);

        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

async function checkUserBalance(token) {
    // 模拟验证用户余额
    return 100; // 假设用户余额为 100
}

async function deductBalance(token, tokensUsed) {
    // 模拟扣费逻辑
    console.log(`用户 ${token} 扣费 ${tokensUsed} tokens`);
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`中间层服务运行在 http://localhost:${PORT}`);
});
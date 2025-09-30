const express = require('express');
const axios = require('axios');
const app = express();

app.get('/', (req, res) => {
    res.send('AI Novel API Platform 服务已启动');
});

app.post('/api/generate', async (req, res) => {
    try {
        const userBalance = await checkUserBalance(req.headers.authorization);
        if (userBalance <= 0) {
            return res.status(403).json({ error: '余额不足，请充值' });
        }
        const response = await axios.post('https://api.deepseek.com/chat/completions', req.body);
        res.status(200).json(response.data);
    } catch (error) {
        res.status(500).json({ error: '服务异常' });
    }
});

module.exports = app;
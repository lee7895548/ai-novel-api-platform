const express = require('express');
const axios = require('axios');
const app = express();

app.get('/', (req, res) => {
    res.send('AI Novel API Platform 服务已启动');
});

app.post('/api/generate', async (req, res) => {
    try {
        // 暂时移除余额检查
        const response = await axios.post('https://api.deepseek.com/chat/completions', req.body);
        res.status(200).json(response.data);
    } catch (error) {
        res.status(500).json({ error: '服务异常' });
    }
});

module.exports = app;
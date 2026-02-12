import axios from 'axios';

const API_URL = '/api/items';

const api = axios.create({
    baseURL: API_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

export const getItems = () => api.get('');
export const createItem = (item) => api.post('', item);
export const updateItem = (id, item) => api.put(`/${id}`, item);
export const deleteItem = (id) => api.delete(`/${id}`);

export default api;

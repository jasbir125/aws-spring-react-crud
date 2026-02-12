import React, { useEffect, useState } from 'react';
import { getItems, deleteItem } from '../services/api';

const ItemList = ({ onEdit, refreshTrigger }) => {
    const [items, setItems] = useState([]);

    useEffect(() => {
        fetchItems();
    }, [refreshTrigger]);

    const fetchItems = async () => {
        try {
            const response = await getItems();
            setItems(response.data);
        } catch (error) {
            console.error("Error fetching items:", error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm("Are you sure you want to delete this item?")) {
            try {
                await deleteItem(id);
                fetchItems();
            } catch (error) {
                console.error("Error deleting item:", error);
            }
        }
    };

    return (
        <div className="list-container">
            <h2>Items List</h2>
            {items.length === 0 ? (
                <p>No items found.</p>
            ) : (
                <ul className="item-list">
                    {items.map((item) => (
                        <li key={item.id} className="item-card">
                            <div className="item-info">
                                <h3>{item.name}</h3>
                                <p>{item.description}</p>
                            </div>
                            <div className="item-actions">
                                <button onClick={() => onEdit(item)} className="btn btn-edit">Edit</button>
                                <button onClick={() => handleDelete(item.id)} className="btn btn-delete">Delete</button>
                            </div>
                        </li>
                    ))}
                </ul>
            )}
        </div>
    );
};

export default ItemList;

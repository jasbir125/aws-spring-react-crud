import React, { useState, useEffect } from 'react';

const ItemForm = ({ currentItem, onSave, onCancel }) => {
    const [item, setItem] = useState({ name: '', description: '' });

    useEffect(() => {
        if (currentItem) {
            setItem(currentItem);
        } else {
            setItem({ name: '', description: '' });
        }
    }, [currentItem]);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setItem({ ...item, [name]: value });
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        onSave(item);
        setItem({ name: '', description: '' });
    };

    return (
        <div className="form-container">
            <h2>{currentItem ? 'Edit Item' : 'Add New Item'}</h2>
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label>Name</label>
                    <input
                        type="text"
                        name="name"
                        value={item.name}
                        onChange={handleChange}
                        required
                    />
                </div>
                <div className="form-group">
                    <label>Description</label>
                    <textarea
                        name="description"
                        value={item.description}
                        onChange={handleChange}
                        required
                    />
                </div>
                <div className="form-actions">
                    <button type="submit" className="btn btn-primary">
                        {currentItem ? 'Update' : 'Add'}
                    </button>
                    {currentItem && (
                        <button type="button" onClick={onCancel} className="btn btn-secondary">
                            Cancel
                        </button>
                    )}
                </div>
            </form>
        </div>
    );
};

export default ItemForm;

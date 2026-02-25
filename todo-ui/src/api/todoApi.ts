import type { Todo } from "../types/Todo";

const API = import.meta.env.VITE_API_URL + "/todos";

export const getTodos = async (): Promise<Todo[]> => {
  const res = await fetch(API);
  return res.json();
};

export const createTodo = async (title: string) => {
  await fetch(API, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title, completed: false })
  });
};

export const deleteTodo = async (id: number) => {
  await fetch(`${API}/${id}`, { method: "DELETE" });
};

export const updateTodo = async (todo: Todo) => {
  await fetch(`${API}/${todo.id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(todo)
  });
};
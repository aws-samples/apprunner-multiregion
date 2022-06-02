import type { NextPage } from "next";
import Head from "next/head";
import styles from "../styles/Home.module.css";
import useSWR, { mutate } from "swr";
import React, { useState } from "react";

async function httpGet(url: string) {
  const resp = await fetch(url);
  return resp.json();
}

async function httpPost(url: string, payload: any) {
  return fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

async function httpDelete(url: string) {
  return fetch(url, { method: "DELETE" });
}

const Home: NextPage = () => {
  const api = "/api/items";
  const { data, error } = useSWR(api, httpGet, {
    revalidateOnFocus: false,
  });
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [httpError, setHttpError] = useState("");

  const handleSubmit = async (evt: any) => {
    evt.preventDefault();

    const payload = {
      title: title,
      description: description,
    };

    console.log(payload);
    const res = await httpPost(api, payload);
    console.log(res);
    if (res.status === 201) {
      setHttpError("");
      mutate(api);
    } else {
      const body = await res.json();
      console.log(body);
      setHttpError(body.error);
    }
  };

  const handleDelete = async (id: string) => {
    console.log("delete", id);
    const res = await httpDelete(`${api}/${id}`);
    mutate(api);
  };

  if (!error && !data) return <div>Loading...</div>;

  let errorComponent = <span />;
  if (error) errorComponent = <div>Error: {error}</div>;
  if (httpError) errorComponent = <div>Error: {httpError}</div>;

  return (
    <div className={styles.container}>
      <Head>
        <title>App Runner Multi-Region App</title>
        <meta name="description" content="App Runner Multi-Region App" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <h1 className={styles.title}>App Runner</h1>
        <h2>Multi-Region App</h2>

        <div className={styles.centercard}>
          <h2>
            <form onSubmit={handleSubmit}>
              <label className={styles.label}>
                Add Item
                <input
                  name="title"
                  type="text"
                  placeholder="Title"
                  className={styles.textbox}
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                />
              </label>

              <label className={styles.label}>
                <input
                  name="description"
                  type="text"
                  placeholder="Description"
                  className={styles.textbox}
                  onChange={(e) => setDescription(e.target.value)}
                />
              </label>

              <input type="submit" value="Add" className={styles.addbutton} />
            </form>
          </h2>
          {errorComponent}
        </div>

        {/* dynamic */}
        <div className={styles.grid}>
          {data.map((item: any) => {
            return (
              <div className={styles.card} key={item.id}>
                <h2>{item.title}</h2>
                <p style={{ wordWrap: "break-word" }}>{item.description}</p>
                <button
                  className={styles.deletebutton}
                  onClick={() => handleDelete(item.id)}
                >
                  Delete
                </button>
              </div>
            );
          })}
        </div>
      </main>
    </div>
  );
};

export default Home;

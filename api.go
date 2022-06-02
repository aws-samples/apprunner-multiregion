package main

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/jritsema/gotoolbox/web"
	"github.com/segmentio/ksuid"
)

var (
	dynamoClient *dynamodb.Client
	awsConfig    aws.Config
	region       string
)

func init() {
	// Using the SDK's default configuration, loading additional config
	// and credentials values from the environment variables, shared
	// credentials, and shared configuration files
	log.Println("loading go sdk")
	var err error
	awsConfig, err = config.LoadDefaultConfig(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	dynamoClient = dynamodb.NewFromConfig(awsConfig)
	region = os.Getenv("AWS_REGION")
}

func getTable() string {
	table := os.Getenv("DYNAMO_TABLE")
	if table == "" {
		log.Fatal("DYNAMO_TABLE is required but missing")
	}
	return table
}

func healthcheck(r *http.Request) *web.Response {
	return web.DataJSON(http.StatusOK, region, nil)
}

func itemsAPI(r *http.Request) *web.Response {
	log.Printf("%s %s", r.Method, r.RequestURI)
	switch r.Method {
	case "GET":
		return getItems(r)
	case "POST":
		return createItem(r)
	case "DELETE":
		return deleteItem(r)
	default:
		return web.Empty(http.StatusMethodNotAllowed)
	}
}

type ItemKey struct {
	ID string `json:"id"`
}

type Item struct {
	ItemKey
	Title       string `json:"title"`
	Description string `json:"description"`
}

func getItems(r *http.Request) *web.Response {

	ctx := context.Background()
	log.Println("dynamo.Scan()")
	so, err := dynamoClient.Scan(ctx, &dynamodb.ScanInput{
		TableName: aws.String(getTable()),
	})
	if err != nil {
		log.Println(err)
		return web.Empty(http.StatusInternalServerError)
	}
	log.Println("scan result", so.Count)

	result := []Item{}
	err = attributevalue.UnmarshalListOfMaps(so.Items, &result)
	if err != nil {
		log.Printf("failed to unmarshal Dynamodb Scan Items, %v \n", err)
		return web.Empty(http.StatusInternalServerError)
	}

	return web.DataJSON(http.StatusOK, result, nil)
}

func createItem(r *http.Request) *web.Response {

	//unmarshal user item into item struct
	var item Item
	err := json.NewDecoder(r.Body).Decode(&item)
	if err != nil {
		log.Println(err)
		return web.ErrorJSON(http.StatusBadRequest, errors.New("invalid user input"), nil)
	}

	//validate user input data
	if item.Title == "" || len(item.Title) > 256 ||
		item.Description == "" || len(item.Description) > 2048 {
		return web.ErrorJSON(http.StatusBadRequest, errors.New("invalid user input"), nil)
	}

	//add unique id
	item.ID = ksuid.New().String()
	log.Println(item)

	table := getTable()
	av, err := attributevalue.MarshalMap(item)
	if err != nil {
		log.Println(err)
		return web.Empty(http.StatusInternalServerError)
	}
	log.Println("dynamo.PutItem()")
	_, err = dynamoClient.PutItem(context.Background(), &dynamodb.PutItemInput{
		TableName: aws.String(table),
		Item:      av,
	})
	if err != nil {
		log.Printf("dynamo.PutItem(), %v \n", err)
		return web.Empty(http.StatusInternalServerError)
	}

	return web.DataJSON(http.StatusCreated, item, nil)
}

func deleteItem(r *http.Request) *web.Response {
	parts := strings.Split(r.RequestURI, "/")
	id := parts[len(parts)-1]
	log.Println("deleting", id)
	ctx := context.Background()
	table := getTable()

	//delete item based on key
	key := ItemKey{ID: id}
	av, err := attributevalue.MarshalMap(key)
	if err != nil {
		log.Println(err)
		return web.Empty(http.StatusInternalServerError)
	}
	log.Printf("dynamo.DeleteItem()")
	_, err = dynamoClient.DeleteItem(ctx, &dynamodb.DeleteItemInput{
		TableName: aws.String(table),
		Key:       av,
	})
	if err != nil {
		log.Printf("dynamo.DeleteItem(), %v \n", err)
		return web.Empty(http.StatusInternalServerError)
	}

	return web.Empty(http.StatusOK)
}

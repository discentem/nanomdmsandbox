package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/goccy/go-graphviz"

	"github.com/blushft/go-diagrams/diagram"
	"github.com/blushft/go-diagrams/nodes/gcp"
)

func main() {

	fmt.Println(os.Getwd())

	d, err := diagram.New(diagram.Filename("app"), diagram.Label("App"), diagram.Direction("LR"))
	if err != nil {
		log.Fatal(err)
	}

	dns := gcp.Network.Dns(diagram.NodeLabel("DNS"))
	lb := gcp.Network.LoadBalancing(diagram.NodeLabel("NLB"))
	cache := gcp.Database.Memorystore(diagram.NodeLabel("Cache"))
	//db := gcp.Database.Sql(diagram.NodeLabel("Database"))

	dc := diagram.NewGroup("GCP")
	dc.NewGroup("services").
		Label("Service Layer").
		Add(
			gcp.Compute.ComputeEngine(diagram.NodeLabel("Server 1")),
			gcp.Compute.ComputeEngine(diagram.NodeLabel("Server 2")),
			gcp.Compute.ComputeEngine(diagram.NodeLabel("Server 3")),
		).
		ConnectAllFrom(lb.ID(), diagram.Forward()).
		ConnectAllTo(cache.ID(), diagram.Forward())

	dc.NewGroup("data").Label("Data Layer").Add(cache).Connect(cache, lb)

	d.Connect(dns, lb, diagram.Forward()).Group(dc)

	if err := d.Render(); err != nil {
		fmt.Println("render failed")
		log.Fatal(err)
	}

	path := "go-diagrams/app.dot"
	b, err := ioutil.ReadFile(path)
	if err != nil {
		log.Fatal(err)
	}
	_, err = graphviz.ParseBytes(b)
	if err != nil {
		log.Fatal(err)
	}
	// 2. get as image.Image instance
	_ = graphviz.New()

	// 3. write to file directly
	// if err := g.RenderFilename(graph, graphviz.SVG, "go-diagrams/graph.svg"); err != nil {
	// 	log.Fatal(err)
	// }
}

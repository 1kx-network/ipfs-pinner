package main

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/ipfs/go-cid"
	pinclient "github.com/sudeepdino008/ipsa-extension"
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// url, ok := os.LookupEnv("PS_URL")
	// if !ok {
	// 	panic("No Pinning Service URL found")
	// }

	// fileUploadUrl, ok := os.LookupEnv("PS_UURL")
	// if !ok {
	// 	panic("No Pinning Upload URL found")
	// }

	key, ok := os.LookupEnv("PS_KEY")
	if !ok {
		panic("No Pinning Service API Key found")
	}

	file := createTempFileForUpload()
	req := pinclient.NewClientRequest(pinclient.Pinata).BearerToken(key)
	client := pinclient.NewClient(req)

	resp, err := client.UploadFile(ctx, file)
	if err != nil {
		panic(err)
	}

	fmt.Printf("pinata pin response is: %v\n", resp.String())

	//	ps1, err1 := c.Add(ctx)

	ipfsPgCid, err := cid.Parse("bafybeiayvrj27f65vbecspbnuavehcb3znvnt2strop2rfbczupudoizya")
	if err != nil {
		panic(err)
	}

	libp2pCid, err := cid.Parse("bafybeiejgrxo4p4uofgfzvlg5twrg5w7tfwpf7aciiswfacfbdpevg2xfy")
	if err != nil {
		panic(err)
	}
	_ = ipfsPgCid

	listPins(ctx, client)

	fmt.Println("Adding libp2p home page")
	ps, err := client.Add(ctx, libp2pCid, pinclient.PinOpts.WithName("libp2p"))
	if err == nil {
		fmt.Printf("PinStatus: %v \n", ps)
	} else {
		fmt.Println(err)
	}

	listPins(ctx, client)

	fmt.Println("Check on pin status")
	if ps == nil {
		panic("Skipping pin status check because the pin is null")
	}

	var pinned bool
	for !pinned {
		status, err := client.GetStatusByID(ctx, ps.GetRequestId())
		if err == nil {
			fmt.Println(status.GetStatus())
			pinned = status.GetStatus() == pinclient.StatusPinned
		} else {
			fmt.Println(err)
		}
		time.Sleep(time.Millisecond * 500)
	}

	listPins(ctx, client)

	fmt.Println("Delete pin")
	err = client.DeleteByID(ctx, ps.GetRequestId())
	if err == nil {
		fmt.Println("Successfully deleted pin")
	} else {
		fmt.Println(err)
	}

	listPins(ctx, client)
}

func listPins(ctx context.Context, c *pinclient.Client) {
	fmt.Println("List all pins")
	pins, err := c.LsSync(ctx)
	if err != nil {
		fmt.Println(err)
	} else {
		for _, p := range pins {
			fmt.Printf("Pin: %v \n", p)
		}
	}
}

func createTempFileForUpload() *os.File {
	f, err := os.CreateTemp(os.TempDir(), "ipsa_extension")
	filepath := f.Name()
	if err != nil {
		panic(err)
	}

	f.Write([]byte("11eebahbahdfdfeebahbahnginx"))
	f.Sync()
	f.Close()

	f, err = os.Open(filepath)
	if err != nil {
		panic(err)
	}

	return f
}
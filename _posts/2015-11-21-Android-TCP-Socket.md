---
layout: entry
title: Android TCP Socket
author: 김성중
author-email: ajax0615@gmail.com
description: 안드로이드 TCP 소켓 프로그래밍 가이드입니다.
publish: true
---

## Server
서버의 기능은 클라이언트에서 오는 데이터를 받아들이는것이 핵심이다. 자신의 포트를 세팅하여 소켓을 여는 것부터 시작하여, 클라이언트에서 오는
정보를 받기 위해서 accept() 를 통해서 기다린다. 그리고 데이터가 왔다는 신호가 오면 리더를 통해서 스트림을 읽어낸다. 그리고 자신이 받은
스트림 정보를 다시 돌려보내는 역할을 한다. 현재는 하나의 클라이언트와 커넥트를 통해 데이터를 주고 받는 형식이다. 많은 클라이언트와 통신하고
싶으면 클라이언트에 대한 정보를 저장하고, 여러 클라이언트에게 적절하게 보내는 기능을 추가하면 된다.

## Client
안드로이드 클라이언트 코드에서는 서버에 소켓을 연결하고 받은 정보를 이용하여 프로그램을 수행시키는 것을 다룬다. 먼저 onCreate()가 되면 서버에
연결하도록 설계되어 있다. IP 주소와 포트 번호를 알맞게 설정해주고, 소켓을 연결한다. 그리고 데이터를 주고 받기 위해서 Read, Write를 설정한다.
예제에서는 간단히 텍스트 박스에 문자를 적고 버튼을 누르면, 서버로 데이터를 보낸다. 그리고 서버에서 오는 데이터를 계속 받기 위해서 while을 쓰레드를
통해서 실행한다. 여기서 받은 데이터 정보를 토스트 기능을 통해 출력한다. 여기서 UI에 대한 접근을 핸들러를 통해서 하고 있는 것을 확인할 수 있다.
UI에 대한 접근은 핸들러를 통해서 수행한다고 생각하고 프로그램을 수행해야한다는 것만 기억하면 될 것 같다.


### Server

    public class NewClient extends Activity {

        private String html = "";
        private Handler mHandler;

        private Socket socket;

        private BufferedReader networkReader;
        private BufferedWriter networkWriter;

        private String ip = "xxx.xxx.xxx.xxx"; // IP
        private int port = 9999; // PORT번호

        @Override
        protected void onStop() {
            super.onStop();
            try {
                socket.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.main);
            mHandler = new Handler();

            try {
                setSocket(ip, port);
            } catch (IOException e1) {
                e1.printStackTrace();
            }

            checkUpdate.start();

            final EditText et = (EditText) findViewById(R.id.EditText01);
            Button btn = (Button) findViewById(R.id.Button01);
            final TextView tv = (TextView) findViewById(R.id.TextView01);

            btn.setOnClickListener(new OnClickListener() {

                public void onClick(View v) {
                    if (et.getText().toString() != null || !et.getText().toString().equals("")) {
                        PrintWriter out = new PrintWriter(networkWriter, true);
                        String return_msg = et.getText().toString();
                        out.println(return_msg);
                    }
                }
            });
        }

        private Thread checkUpdate = new Thread() {

            public void run() {
                try {
                    String line;
                    Log.w("ChattingStart", "Start Thread");
                    while (true) {
                        Log.w("Chatting is running", "chatting is running");
                        line = networkReader.readLine();
                        html = line;
                        mHandler.post(showUpdate);
                    }
                } catch (Exception e) {

                }
            }
        };

        private Runnable showUpdate = new Runnable() {

            public void run() {
                Toast.makeText(NewClient.this, "Coming word: " + html, Toast.LENGTH_SHORT).show();
            }

        };

        public void setSocket(String ip, int port) throws IOException {

            try {
                socket = new Socket(ip, port);
                networkWriter = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream()));
                networkReader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            } catch (IOException e) {
                System.out.println(e);
                e.printStackTrace();
            }

        }

    }


### Client

    public class TCPServer implements Runnable {

        public static final int ServerPort = 9999;
        public static final String ServerIP = "xxx.xxx.xxx.xxxx";

        @Override
        public void run() {

            try {
                System.out.println("S: Connecting...");
                ServerSocket serverSocket = new ServerSocket(ServerPort);

                while (true) {
                    Socket client = serverSocket.accept();
                    System.out.println("S: Receiving...");
                    try {
                        BufferedReader in = new BufferedReader(new InputStreamReader(client.getInputStream()));
                        String str = in.readLine();
                        System.out.println("S: Received: '" + str + "'");

                        PrintWriter out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(client.getOutputStream())), true);
                        out.println("Server Received " + str);
                    } catch (Exception e) {
                        System.out.println("S: Error");
                        e.printStackTrace();
                    } finally {
                        client.close();
                        System.out.println("S: Done.");
                    }
                }
            } catch (Exception e) {
                System.out.println("S: Error");
                e.printStackTrace();
            }
        }

        public static void main(String[] args) {

            Thread desktopServerThread = new Thread(new TCPServer());
            desktopServerThread.start();

        }
    }

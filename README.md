# README

RCON https://github.com/koraktor/steam-condenser-ruby



# 서버 세팅방법

```bash
config/database.yml 파일에 적힌 한글 안내에 맞도록수정해줍니다.

Ruby 2.6.3 설치
sudo gem install bundler

bundle install

rails db:create
rails db:migrate

를 순서대로 명령어에 쳐주시면 됩니다.

레일즈 서버는 apache + passenger 로 올리시는걸 추천드립니다.
아래 내용들을 읽어보며 셋팅시 바로 사용 가능합니다.

documents 폴더 아래에 있는 플러그인들은 서버에 넣어주시면됩니다.
```



## Admin/Cron 에서 등록해줘야되는것

`update_player`, `check_notice` 를 job 이름으로 등록해주어야 플레이어 리스트,서버 공지사항이 갱신됨
`duration` : 초단위 새로고침



## Scheduling



https://dev.to/risafj/cron-jobs-in-rails-a-simple-guide-to-actually-using-the-whenever-gem-now-with-tasks-2omi



```ruby
gem 'whenever', require: false
```



```bash
every 1.minute do
  rake 'batch:send_messages'
end
```



```bash
bundle exec whenever --update-crontab --set environment='production'
```

crontab 다음과같이 수정하면 됩니다 (zsh 쉘 사용시 환경변수 가져오기)

```bash
* * * * * /bin/zsh -c 'source ~/.zshrc && cd /WorkSpace/Rust_Rails && RAILS_ENV=production bundle exec rake batch:execute_cron --silent >> ./log/schedule.log 2>&1'
```

```bash
* * * * * /bin/zsh -c 'source ~/.zshrc && cd /WorkSpace/Rust_Rails && RAILS_ENV=production bundle exec rake batch:execute_cron --silent >> ./log/schedule.log 2>&1 && sleep 10 && RAILS_ENV=production bundle exec rake batch:execute_cron --silent >> ./log/schedule.log 2>&1 && sleep 10 && RAILS_ENV=production bundle exec rake batch:execute_cron --silent >> ./log/schedule.log 2>&1 && sleep 10 && RAILS_ENV=production bundle exec rake batch:execute_cron --silent >> ./log/schedule.log 2>&1 && sleep 10 && RAILS_ENV=production bundle exec rake batch:execute_cron --silent >> ./log/schedule.log 2>&1'
```

10초마다 작동할경우

```
time    attacker id      target           id      weapon                                                           ammo area    distance old_hp new_hp info
```





## Oxide Plugin - CombatLogger

서버측으로 수정사항을 넘기기위해 몇가지 작업이 필요했다. documents 하단 폴더에 있음

```csharp
// 변경 : 함수추가
		private void SendToServer(String message){
			Puts("SendTo SERVER!!!!!!!");
			var secret = "kuuwang";
			var servername = "Playrust.co.kr%23와컴";
			// 변경 : 서버정보

			webrequest.Enqueue($"https://rust.kuuwang.com/combatlog?secret={secret}&server={servername}&message="+message, null, (code, response) =>
			{
				if (code != 200 || response == null)
				{
					Puts($"Couldn't get an answer");
					return;
				}
				// Puts($"Google answered: {response}");
				Puts("Send to Server Success.");
			}, this, RequestMethod.GET);
		}
		
```

이부분에서 secret, servername은 변경해줘야한다.

servername < 홈페이지에 등록된 서버의 타이틀을 적어줘야됨.

%23 < # 을 의미 urlencode 해줄것!







## 어드민 서버 초기화 관련

-   Workd reset Type : 들어갈 수 있는 글자는 다음과 같다. ( 서버 전체 초기화 / 블루프린트, 맵)

    **대소문자 구분할것**

    -   1Week
    -   2Week
    -   3Week
    -   4Week
    -   1Month (시작일을 기준으로 1개월마다)
    -   2Month (시작일을 기준으로 2개월마다)
    -   3Month (시작일을 기준으로 3개월마다)
    -   4Month (시작일을 기준으로 4개월마다)
    -   5Month (시작일을 기준으로 5개월마다)
    -   6Month (시작일을 기준으로 6개월마다)
    -   1_Month (달에 한번 실행 / 시작일을 기준으로 다음 달 같은 요일까지 1번)
    -   2_Month (달에 두번 실행 / 시작일을 기준으로 다음 달 같은 요일까지 2번)
    -   3_Month (달에 세번 실행 / 시작일을 기준으로 다음 달 같은 요일까지 3번)
    -   U_Month (업데이트 날에 실행, 달의 중간에 실행 / 날짜 기준은 시작일로부터 다음 달 같은 요일)

-   Map reset Type : 들어갈 수 있는 글자는 다음과 같다. (맵 초기화)
    -   1Week
    -   2Week
    -   3Week
    -   4Week
    -   1Month (시작일을 기준으로 1개월마다)
    -   2Month (시작일을 기준으로 2개월마다)
    -   3Month (시작일을 기준으로 3개월마다)
    -   4Month (시작일을 기준으로 4개월마다)
    -   5Month (시작일을 기준으로 5개월마다)
    -   6Month (시작일을 기준으로 6개월마다)
    -   1_Month (달에 한번 실행 / 시작일을 기준으로 다음 달 같은 요일까지 1번)
    -   2_Month (달에 두번 실행 / 시작일을 기준으로 다음 달 같은 요일까지 2번)
    -   3_Month (달에 세번 실행 / 시작일을 기준으로 다음 달 같은 요일까지 3번)
    -   U_2_Month (업데이트 날에 실행, 달의 중간에 실행 / 날짜 기준은 시작일로부터 다음 달 같은 요일)

-   Start date : 시작일 이며, 초기화가 지난 후에는 위 옵션에 따라 계산됨

-   World Reset Count : 월드 리셋이 이루어진 횟수

-   Map Reset Count : 맵 초기화가 이루어진 횟수

-   World reset command : 관리자가 작성하는 실행될 커맨드

-   Map reset command : 관리자가 작성하는 실행될 커맨드

-   World reset Notice Message : 월드 리셋이 실행되기 10초전 공지

-   Map reset Notice Message : 맵 초기화가 실행되기 10초전 공지



# 마지막 홈페이지 사진

![스크린샷 2020-03-08 오전 12.36.03](README.assets/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202020-03-08%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%2012.36.03.png)

![스크린샷 2020-03-08 오전 12.36.06](README.assets/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202020-03-08%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%2012.36.06.png)

![스크린샷 2020-03-08 오전 12.36.08](README.assets/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202020-03-08%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%2012.36.08.png)

![스크린샷 2020-03-08 오전 12.36.18](README.assets/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202020-03-08%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%2012.36.18.png)



## Credit.

**이제껏 같이 서버를 운영해온 M2[마나] WACOM[San_ha], KUUWANGE [shellcodesniper] 에 감사인사를 드립니다.**
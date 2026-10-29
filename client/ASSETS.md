# 미리보기 이미지 및 font

행사 이름·날짜·후기는 허구의 UI 예시입니다. 아래 사진은 분위기를 보여주는 시안용 이미지이며 예시 행사의 실제 사진임을 주장하지 않습니다. 직접 다운로드해 확인한 원본 URL을 기록했습니다. 기사·소개 페이지 사진의 재배포 라이선스는 확인하지 않았으므로 실제 공개 서비스에서는 사용권을 확인하거나 자체/허가된 이미지로 교체해야 합니다.

| 로컬 파일                         | 확인한 원본 또는 출처                                                                                                                                                                                                    |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `public/images/garden.jpg`        | [여기유 아침고요수목원 국화전시회](https://xn--ok0b236bp0a.com/place/27725) · [이미지](https://image.xn--ok0b236bp0a.com/content_festival/2023101614185016974335304339.jpg)                                              |
| `public/images/palace.jpg`        | [에스콰이어 가을 문화산책 행궁동 데이트 코스](https://www.esquirekorea.co.kr/article/72131) · [이미지](https://www.esquirekorea.co.kr/resources_old/online/org_online_image/eq/e1d85bbf-fb35-4237-be90-f937aa38a5cc.jpg) |
| `public/images/flowers.jpg`       | [동포저널 인제 가을꽃 축제 기사](https://www.dongpojournal.com/news/articleView.html?idxno=2002440) · [이미지](https://cdn.dongpojournal.com/news/photo/202410/2002440_14100_5021.jpeg)                                  |
| `public/images/music.jpg`         | [확인한 Unsplash 이미지](https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=1200&q=85)                                                                                                  |
| `public/images/market.jpg`        | [확인한 Unsplash 이미지](https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=1200&q=85)                                                                                                  |
| `public/images/art.jpg`           | [확인한 Unsplash 이미지](https://images.unsplash.com/photo-1577083552431-6e5fd01aa342?auto=format&fit=crop&w=1200&q=85)                                                                                                  |
| `public/PretendardVariable.woff2` | [Pretendard 1.3.9 배포 파일](https://cdn.jsdelivr.net/npm/pretendard@1.3.9/dist/web/variable/woff2/PretendardVariable.woff2) · 동봉한 `public/Pretendard-LICENSE.txt` 참조                                               |

로고는 직접 작성한 SVG이고, UI 아이콘은 설치한 `lucide-react` 패키지를 사용합니다. 배경, 카드, ticket 장식은 CSS로 구현했습니다.

## 운영 화면의 예시 데이터 사진

운영 DB 예시 데이터(`src/main/resources/db/showcase/R__showcase_popup_demo.sql`)의 회원 제보 행사·후기·커뮤니티 글은 아래 Unsplash 무료 사진(Unsplash License)을 `images.unsplash.com`에서 그대로 불러옵니다. 파일로 저장하지 않으며 Unsplash+ 유료 사진은 쓰지 않았습니다. 사진은 분위기를 보여주는 이미지이고, 제보한 팝업의 실제 사진이 아닙니다.

| 이름              | 사진                                                                                             |
| ----------------- | ------------------------------------------------------------------------------------------------ |
| `latteArt`        | [photo-1742549626436-bf3c11dab212](https://images.unsplash.com/photo-1742549626436-bf3c11dab212) |
| `cafeLatte`       | [photo-1559001724-fbad036dbc9e](https://images.unsplash.com/photo-1559001724-fbad036dbc9e)       |
| `matchaLatte`     | [photo-1766426910014-63a302fa137e](https://images.unsplash.com/photo-1766426910014-63a302fa137e) |
| `icedMatcha`      | [photo-1785711571852-8edfd71e92ef](https://images.unsplash.com/photo-1785711571852-8edfd71e92ef) |
| `coffeeShop`      | [photo-1567880905822-56f8e06fe630](https://images.unsplash.com/photo-1567880905822-56f8e06fe630) |
| `serumShelf`      | [photo-1787569499510-ef18cc7ba7a5](https://images.unsplash.com/photo-1787569499510-ef18cc7ba7a5) |
| `amberDropper`    | [photo-1608571423902-eed4a5ad8108](https://images.unsplash.com/photo-1608571423902-eed4a5ad8108) |
| `creamSwatch`     | [photo-1585945037805-5fd82c2e60b1](https://images.unsplash.com/photo-1585945037805-5fd82c2e60b1) |
| `saunaRoom`       | [photo-1759302353458-3c617bfd428b](https://images.unsplash.com/photo-1759302353458-3c617bfd428b) |
| `toyStoryFigures` | [photo-1718804715033-8e045415f6f3](https://images.unsplash.com/photo-1718804715033-8e045415f6f3) |
| `colorfulToys`    | [photo-1663850697008-29fd8ea8e941](https://images.unsplash.com/photo-1663850697008-29fd8ea8e941) |
| `figureShelf`     | [photo-1608278047522-58806a6ac85b](https://images.unsplash.com/photo-1608278047522-58806a6ac85b) |
| `characterShop`   | [photo-1792019626300-2911392d6c82](https://images.unsplash.com/photo-1792019626300-2911392d6c82) |
| `keychainWall`    | [photo-1764788127523-ac9fd80be5f3](https://images.unsplash.com/photo-1764788127523-ac9fd80be5f3) |
| `teddyOnSofa`     | [photo-1641085809270-71f722611ce1](https://images.unsplash.com/photo-1641085809270-71f722611ce1) |
| `teddyBowtie`     | [photo-1602734846297-9299fc2d4703](https://images.unsplash.com/photo-1602734846297-9299fc2d4703) |
| `autumnGarden`    | [photo-1581524070124-957d29ec032f](https://images.unsplash.com/photo-1581524070124-957d29ec032f) |
| `parkPath`        | [photo-1742744132094-26fa77a4163f](https://images.unsplash.com/photo-1742744132094-26fa77a4163f) |
| `autumnPond`      | [photo-1619441207978-3d326c46e2c9](https://images.unsplash.com/photo-1619441207978-3d326c46e2c9) |
| `marketCrates`    | [photo-1631692994621-d26f83cf4db8](https://images.unsplash.com/photo-1631692994621-d26f83cf4db8) |
| `stationeryShop`  | [photo-1779684998897-ce5de594a5ac](https://images.unsplash.com/photo-1779684998897-ce5de594a5ac) |
| `shelfGoods`      | [photo-1598305762558-328f599df683](https://images.unsplash.com/photo-1598305762558-328f599df683) |
| `pinkTumbler`     | [photo-1729192293999-ffbdc97cbac9](https://images.unsplash.com/photo-1729192293999-ffbdc97cbac9) |
| `bottles`         | [photo-1679310289576-8e1b68b808ba](https://images.unsplash.com/photo-1679310289576-8e1b68b808ba) |
| `hoodedJacket`    | [photo-1567955465154-078c60ff5c9e](https://images.unsplash.com/photo-1567955465154-078c60ff5c9e) |
| `brownJacket`     | [photo-1649937408746-4d2f603f91c8](https://images.unsplash.com/photo-1649937408746-4d2f603f91c8) |
| `gameOnNeon`      | [photo-1546443046-ed1ce6ffd1ab](https://images.unsplash.com/photo-1546443046-ed1ce6ffd1ab)       |
| `cdWall`          | [photo-1760931657888-87514a4e6c25](https://images.unsplash.com/photo-1760931657888-87514a4e6c25) |
| `photoBooth`      | [photo-1744189578759-5103cc188897](https://images.unsplash.com/photo-1744189578759-5103cc188897) |
| `brickStreet`     | [photo-1652618959145-1d58531713d4](https://images.unsplash.com/photo-1652618959145-1d58531713d4) |
| `redBrick`        | [photo-1697201193383-601d4f3b7339](https://images.unsplash.com/photo-1697201193383-601d4f3b7339) |
| `queue`           | [photo-1743324754696-c636e1aed0b6](https://images.unsplash.com/photo-1743324754696-c636e1aed0b6) |
| `mallAtrium`      | [photo-1761333485882-c60907725574](https://images.unsplash.com/photo-1761333485882-c60907725574) |
| `galleryCrowd`    | [photo-1743119844808-fefd446de533](https://images.unsplash.com/photo-1743119844808-fefd446de533) |
| `museumHall`      | [photo-1774514580599-c3dae376348e](https://images.unsplash.com/photo-1774514580599-c3dae376348e) |
| `hamster`         | [photo-1425082661705-1834bfd09dca](https://images.unsplash.com/photo-1425082661705-1834bfd09dca) |
| `toteBag`         | [photo-1544816155-12df9643f363](https://images.unsplash.com/photo-1544816155-12df9643f363)       |
| `stickerWall`     | [photo-1625768376503-68d2495d78c5](https://images.unsplash.com/photo-1625768376503-68d2495d78c5) |
| `stickerCollage`  | [photo-1778278553405-09b847a2af3e](https://images.unsplash.com/photo-1778278553405-09b847a2af3e) |
| `cinemaHall`      | [photo-1762541693135-fb989de961e1](https://images.unsplash.com/photo-1762541693135-fb989de961e1) |

마도카 마기카 〈발푸르기스의 회천〉 팝업의 표지와 그 후기의 첫 사진은 [팝가 행사 페이지](https://popga.co.kr/popup/14165)에 올라온 공식 포스터를 그 주소 그대로 불러옵니다. 작품 포스터라 저작권은 권리자에게 있습니다.

import re
import os
import urllib
import time

import requests
from lxml import etree


class CheChiSpider(object):
    url = "http://www.5nj.com/?m=vod-play-id-147870-src-1-num-1.html"


    @classmethod
    def get_origin_m3u8_url_list(cls, video_url):
        """从页面获取原始的m3u8的url"""
        resp = requests.get(video_url)
        html = etree.HTML(resp.content)
        origin_infos = html.xpath("""//div[@class="main"]/script""")[0].text
        origin_urls = re.findall(r"unescape\(\'(.*?)\'\)", origin_infos)[0]
        parsed_urls = urllib.parse.unquote(origin_urls).split(r"$$$")[0]
        m3u8_url_list = re.findall(r"https:\/.*?\/index.m3u8", parsed_urls)
        return m3u8_url_list

    @classmethod
    def get_real_m3u8_url(cls, m3_url):
        """从原始的m3u8的url获取真实的m3u8url"""
        resp = requests.get(m3_url)
        url_path = resp.text.split("\n")[-1]
        new_m3u8_url = cls.repalce_url_end_path(m3_url, url_path)
        return new_m3u8_url

    @classmethod
    def get_ts(cls, real_m3url):
        """从m3u8的url获取其中的ts文件地址"""
        ts_infos = requests.get(real_m3url).text
        all_ts_path = re.findall(r"(.*?\.ts)", ts_infos)
        full_all_ts_path = [cls.repalce_url_end_path(real_m3url, x) for x in all_ts_path]
        return full_all_ts_path

    @classmethod
    def download_from_m3u8(cls, m3u8_url, dir_path, file_name):
        file_path = "{}/{}.mp4".format(dir_path, file_name)
        if os.path.exists(file_path):
            return
        os.system("ffmpeg -i {} -acodec copy -vcodec copy -absf aac_adtstoasc {}".format(m3u8_url, file_path))


    @classmethod
    def repalce_url_end_path(cls, url, end_path):
        a = url.split("/")[:-1]
        a.append(end_path)
        return "/".join(a)

if __name__ == "__main__":
    t1 = time.time()
    ourl = CheChiSpider.get_origin_m3u8_url_list("http://www.5nj.com/?m=vod-play-id-121691-src-1-num-1.html")
    for i,x in enumerate(ourl):
        m3url = CheChiSpider.get_real_m3u8_url(x)
        print(m3url)
        CheChiSpider.download_from_m3u8(m3url, "/Users/dengrunting/Documents/电视剧/圆月弯刀", str(i+1))
    print("耗时:{}".format(time.time() - t1))

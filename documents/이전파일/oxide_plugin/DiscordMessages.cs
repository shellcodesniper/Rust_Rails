﻿using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using Oxide.Core;
using Oxide.Core.Libraries;
using Oxide.Core.Libraries.Covalence;
using Oxide.Core.Plugins;

namespace Oxide.Plugins
{
    [Info("DiscordMessages", "Slut", "2.1.2")]
    class DiscordMessages : CovalencePlugin
    {
		#region PlayerChat


		// 변경 : 함수추가
		private void SendToServer(String message)
		{
			Puts("SendTo SERVER!!!!!!!");
			var secret = "kuuwang";
			var servername = "Playrust.co.kr%23뉴비";
			// 변경 : 서버정보

			webrequest.Enqueue($"https://rust.kuuwang.com/messagelog?secret={secret}&server={servername}&message=" + message, null, (code, response) =>
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
        private void OnUserChat(IPlayer player, string message)
        {
            if (!GetFeatureConfig<Configuration.Chat>(FeatureType.PlayerChat).Enabled)
            {
                return;
            }

            if (BetterChatMute?.Call<bool>("API_IsMuted", player) ?? false)
            {
                return;
            }
            if (AdminChat?.Call<bool>("HasAdminChatEnabled", player) ?? false)
            {
                return;
            }
            
            if (!player.HasPermission(AdminPermission)) message = message.Replace("@everyone", "@ everyone").Replace("@here", "@ here");
            var chatConfig = GetFeatureConfig<Configuration.Chat>(FeatureType.PlayerChat);
            var discordMessage = $"[{DateTime.Now.ToShortTimeString()}] {GetLang("PlayerChatFormat", null, player.Name, message)}";
			Request.Send(chatConfig.WebhookUrl, new FancyMessage().WithContent(discordMessage).AsTTS(chatConfig.TextToSpeech), this);
			
			
			// 변경 : 여기서 보내기
			var serverMessage = $"{GetLang("PlayerChatFormat", null, player.Name, message)}"; 
			SendToServer(serverMessage);
        }

        #endregion

        #region Message

        private void MessageCommand(IPlayer player, string command, string[] args)
        {
            if (args.Length < 1)
            {
                SendMessage(player, GetLang("MessageSyntax", player.Id));
                return;
            }

            var messageConfig = GetFeatureConfig<Configuration.Message>(FeatureType.Message);
            if (OnCooldown(player, CooldownType.MessageCooldown))
            {
                var messageCooldown = _data.Players[player.Id].MessageCooldown;
                if (messageCooldown != null)
                    SendMessage(player,
                        GetLang("Cooldown", player.Id,
                            (messageCooldown.Value.AddSeconds(messageConfig.Cooldown) -
                             DateTime.UtcNow).Seconds));
                return;
            }

            var message = string.Join(" ", args.ToArray());
            var builder = new EmbedBuilder()
                .WithTitle(GetLang("Embed_MessageTitle"))
                .AddInlineField(GetLang("Embed_MessagePlayer"), $"[{player.Name}](https://steamcommunity.com/profiles/{player.Id})")
                .AddField(GetLang("Embed_MessageMessage"), message)
                .SetColor(messageConfig.Color);
            var payload = new FancyMessage()
                .WithContent(messageConfig.Alert)
                .SetEmbed(builder);
            Request.Send(messageConfig.WebhookUrl, payload, response =>
            {
                if (response.IsOk)
                {
                    SendMessage(player, GetLang("MessageSent", player.Id));
                    if (_data.Players.ContainsKey(player.Id))
                    {
                        _data.Players[player.Id].MessageCooldown = DateTime.UtcNow;
                    }
                    else
                    {
                        _data.Players.Add(player.Id, new PlayerData());
                        _data.Players[player.Id].MessageCooldown = DateTime.UtcNow;
                    }

                    if (messageConfig.LogToConsole) Puts($"MESSAGE ({player.Name}/{player.Id}) : {message}");
                }
                else if (response.IsBad)
                {
                    SendMessage(player, GetLang("MessageNotSent", player.Id));
                }
            }, this);
        }

        #endregion

        #region Classes

        private class Data
        {
            public Dictionary<string, PlayerData> Players = new Dictionary<string, PlayerData>();
        }

        private class PlayerData
        {
            public int Reports { get; set; }
            public DateTime? ReportCooldown { get; set; }
            public DateTime? MessageCooldown { get; set; }
            public bool ReportDisabled { get; set; }
        }

        public class FancyMessage
        {
            [JsonProperty("content")] private string Content { get; set; }

            [JsonProperty("tts")] private bool TextToSpeech { get; set; }

            [JsonProperty("embeds")] private EmbedBuilder[] Embeds { get; set; }

            public FancyMessage WithContent(string value)
            {
                Content = value;
                return this;
            }

            public FancyMessage AsTTS(bool value)
            {
                TextToSpeech = value;
                return this;
            }

            public FancyMessage SetEmbed(EmbedBuilder value)
            {
                Embeds = new[]
                {
                    value
                };
                return this;
            }

            public string GetContent()
            {
                return Content;
            }

            public bool IsTTS()
            {
                return TextToSpeech;
            }

            public EmbedBuilder GetEmbed()
            {
                return Embeds[0];
            }

            public string ToJson()
            {
                return JsonConvert.SerializeObject(this, _instance._jsonSettings);
            }
        }

        public class EmbedBuilder
        {
            public EmbedBuilder()
            {
                Fields = new List<Field>();
            }

            [JsonProperty("title")] private string Title { get; set; }

            [JsonProperty("color")] private int Color { get; set; }

            [JsonProperty("fields")] private List<Field> Fields { get; }

            [JsonProperty("description")] private string Description { get; set; }

            public EmbedBuilder WithTitle(string title)
            {
                Title = title;
                return this;
            }

            public EmbedBuilder WithDescription(string description)
            {
                Description = description;
                return this;
            }

            public EmbedBuilder SetColor(int color)
            {
                Color = color;
                return this;
            }

            public EmbedBuilder SetColor(string color)
            {
                Color = ParseColor(color);
                return this;
            }

            public EmbedBuilder AddInlineField(string name, object value)
            {
                Fields.Add(new Field(name, value, true));
                return this;
            }

            public EmbedBuilder AddField(string name, object value)
            {
                Fields.Add(new Field(name, value, false));
                return this;
            }

            public EmbedBuilder AddField(Field field)
            {
                Fields.Add(field);
                return this;
            }

            public int GetColor()
            {
                return Color;
            }

            public string GetTitle()
            {
                return Title;
            }

            public Field[] GetFields()
            {
                return Fields.ToArray();
            }

            private int ParseColor(string input)
            {
                int color;
                if (!int.TryParse(input, out color)) color = 3329330;
                return color;
            }

            internal class Field
            {
                public Field(string name, object value, bool inline)
                {
                    Name = name;
                    Value = value;
                    Inline = inline;
                }

                [JsonProperty("name")] public string Name { get; set; }

                [JsonProperty("value")] public object Value { get; set; }

                [JsonProperty("inline")] public bool Inline { get; set; }
            }
        }

        private abstract class Response
        {
            public int Code { get; set; }
            public string Message { get; set; }
        }

        private class BaseResponse : Response
        {
            public bool IsRatelimit => Code == 429;
            public bool IsOk => (Code == 200) | (Code == 204);
            public bool IsBad => !IsRatelimit && !IsOk;

            public RateLimitResponse GetRateLimit()
            {
                return JsonConvert.DeserializeObject<RateLimitResponse>(Message);
            }
        }

        private class Request
        {
            private static readonly RateLimitHandler handler = new RateLimitHandler();

            private readonly string _payload;
            private readonly Plugin _plugin;
            private readonly Action<BaseResponse> _response;
            private readonly string _url;


            public void Send()
            {
                _instance.webrequest.Enqueue(_url,_payload , (code, rawResponse) =>
                {
                    var response = new BaseResponse
                    {
                        Message = rawResponse,
                        Code = code
                    };
                    if (response.IsRatelimit) handler.AddMessage(response.GetRateLimit(), this);
                    if (response.IsBad) _instance.PrintWarning("Failed! Discord responded with code: {0}. Plugin: {1}\n{2}", code, _plugin != null ? _plugin.Name : "Unknown Plugin", response.Message);
                    try
                    {
                        _response?.Invoke(response);
                    }
                    catch (Exception ex)
                    {
                        Interface.Oxide.LogException("[DiscordMessages] Request callback raised an exception!", ex);
                    }
                }, _instance, RequestMethod.POST, _instance._headers);
            }
            public static void Send(string url, FancyMessage message, Plugin plugin = null)
            {
                new Request(url, message, plugin).Send();
            }
            public static void Send(string url, FancyMessage message, Action<BaseResponse> _callback, Plugin plugin = null)
            {
                new Request(url, message, _callback, plugin).Send();
            }

            private Request(string url, FancyMessage message, Action<BaseResponse> response = null, Plugin plugin = null)
            {
                _url = url;
                _payload = message.ToJson();
                _response = response;
                _plugin = plugin;
            }

            private Request(string url, FancyMessage message, Plugin plugin = null)
            {
                _url = url;
                _payload = message.ToJson();
                _plugin = plugin;
            }

            public float NextTime { get; private set; }

            public Request SetNextTime(float time)
            {
                NextTime = time;
                return this;
            }
        }

        private class RateLimitHandler
        {
            private Queue<Request> Messages { get; } = new Queue<Request>();

            public void AddMessage(RateLimitResponse response, Request request)
            {
                request.SetNextTime((float) response.RetryAfter / 1000);
                Messages.Enqueue(request);
                RateTimerHandler();
            }

            private void RateTimerHandler()
            {
                while (true)
                {
                    if (Messages.Count == 0) return;
                    
                    var request = Messages.Dequeue();
                    _instance.timer.Once(request.NextTime, () => request.Send());
                }
            }
        }

        private class RateLimitResponse : BaseResponse
        {
            [JsonProperty("global")] public bool Global { get; set; }

            [JsonProperty("retry_after")] public int RetryAfter { get; set; }
        }

        private enum CooldownType
        {
            ReportCooldown,
            MessageCooldown
        }

        private enum FeatureType
        {
            Ban,
            Message,
            Report,
            PlayerChat,
            Mute
        }

        #endregion

        #region Configuration

        private Configuration _config;

        private class Configuration
        {
            public General GeneralSettings { get; set; } = new General();

            public Ban BanSettings { get; set; } = new Ban();

            public Report ReportSettings { get; set; } = new Report();

            public Message MessageSettings { get; set; } = new Message();
            public Chat ChatSettings { get; set; } = new Chat();
            public Mute MuteSettings { get; set; } = new Mute();

            [JsonIgnore] public Dictionary<FeatureType, WebhookObject> FeatureTypes { get; set; }

            public static Configuration Defaults()
            {
                return new Configuration();
            }

            public class General
            {
                public bool Announce { get; set; } = true;
            }

            public class Ban : EmbedObject
            {
            }

            public class Message : EmbedObject
            {
                public bool LogToConsole { get; set; } = true;
                public bool SuggestAlias { get; set; } = false;
                public string Alert { get; set; } = "";
                public int Cooldown { get; set; } = 30;
            }

            public class Report : EmbedObject
            {
                public bool LogToConsole { get; set; } = true;
                public string Alert { get; set; } = "";
                public int Cooldown { get; set; } = 30;
            }

            public class Chat : WebhookObject
            {
                public bool TextToSpeech { get; set; } = false;
            }

            public class Mute : EmbedObject
            {
            }

            public class EmbedObject : WebhookObject
            {
                public string Color { get; set; } = "3329330";
            }

            public class WebhookObject
            {
                public bool Enabled { get; set; } = true;
                public string WebhookUrl { get; set; } = "https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks";
            }
        }

        protected override void LoadConfig()
        {
            base.LoadConfig();
            _config = Config.ReadObject<Configuration>();
            _config.FeatureTypes = new Dictionary<FeatureType, Configuration.WebhookObject>
            {
                [FeatureType.Ban] = _config.BanSettings,
                [FeatureType.Report] = _config.ReportSettings,
                [FeatureType.Message] = _config.MessageSettings,
                [FeatureType.Mute] = _config.MuteSettings,
                [FeatureType.PlayerChat] = _config.ChatSettings
            };
        }

        protected override void SaveConfig()
        {
            base.SaveConfig();
            Config.WriteObject(_config);
        }

        protected override void LoadDefaultConfig()
        {
            PrintWarning("Generating new config!");
            _config = Configuration.Defaults();
        }

        private T GetFeatureConfig<T>(FeatureType type) where T : Configuration.WebhookObject
        {
            return (T) _config.FeatureTypes[type];
        }

        #endregion

        #region Variables

        private Data _data;

        [PluginReference] private readonly Plugin BetterChatMute, AdminChat;

        private static DiscordMessages _instance;
        private readonly JsonSerializerSettings _jsonSettings = new JsonSerializerSettings();
        
        private readonly Dictionary<string, string> _headers = new Dictionary<string, string>
        {
            ["Content-Type"] = "application/json"
        };

        #endregion

        #region Hooks / Load

        private void Init()
        {
            _instance = this;
            _jsonSettings.NullValueHandling = NullValueHandling.Ignore;
            LoadData();
            RegisterPermissions();
            if (!_config.FeatureTypes.Any(x => x.Value.Enabled))
            {
                PrintWarning("All functions are disabled. Please enable at least one.");
                Interface.Oxide.UnloadPlugin(Name);
                return;
            }

            foreach (var feature in _config.FeatureTypes)
            {
                var value = feature.Value;
                if (value.Enabled && (value.WebhookUrl == null || value.WebhookUrl == "https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks"))
                {
                    value.Enabled = false;
                    PrintWarning($"{feature.Key} was enabled however the Webhook is incorrect.");
                }
            }

            RegisterCommands();
            CheckHooks();
        }

        private void CheckHooks()
        {
            if (!GetFeatureConfig<Configuration.Chat>(FeatureType.PlayerChat).Enabled) Unsubscribe(nameof(OnUserChat));
            if (!GetFeatureConfig<Configuration.Mute>(FeatureType.Mute).Enabled)
            {
                Unsubscribe(nameof(OnBetterChatMuted));
                Unsubscribe(nameof(OnBetterChatTimeMuted));
            }
        }

        private void Unload()
        {
            SaveData();
            _instance = null;
        }

        private void OnServerSave()
        {
            SaveData();
        }

        private void RegisterCommands()
        {
            if (GetFeatureConfig<Configuration.Report>(FeatureType.Report).Enabled)
            {
                AddCovalenceCommand("report", "ReportCommand", ReportPermission);
                AddCovalenceCommand(new[] {"reportadmin", "ra"}, "ReportAdminCommand", AdminPermission);
            }

            if (GetFeatureConfig<Configuration.Ban>(FeatureType.Ban).Enabled) AddCovalenceCommand("ban", "BanCommand", BanPermission);
            var messageConfig = GetFeatureConfig<Configuration.Message>(FeatureType.Message);
            if (messageConfig.Enabled) AddCovalenceCommand(messageConfig.SuggestAlias ? new[] {"message", "suggest"} : new[] {"message"}, "MessageCommand", MessagePermission);
        }

        protected override void LoadDefaultMessages()
        {
            lang.RegisterMessages(new Dictionary<string, string>
            {
                ["ReportSyntax"] = "Syntax error. Please use /report \"name/id\" \"reason\"",
                ["BanSyntax"] = "Syntax error. Please use /ban \"name/id\" \"reason\"",
                ["MessageSyntax"] = "Syntax error. Please use /message \"your message\"",
                ["Multiple"] = "Multiple players found:\n{0}",
                ["BanMessage"] = "{0} was banned for {1}",
                ["ReportSent"] = "Your report has been sent!",
                ["MessageSent"] = "Your message has been sent!",
                ["NotFound"] = "Unable to find player {0}",
                ["NoReports"] = "{0} has not been reported yet!",
                ["ReportDisallowed"] = "You have been blacklisted from reporting players.",
                ["ReportAccessChanged"] = "Report feature for {0} is now {1}",
                ["ReportReset"] = "You have reset the report count for {0}",
                ["Cooldown"] = "You must wait {0} seconds to use this command again.",
                ["AlreadyBanned"] = "{0} is already banned!",
                ["NoPermission"] = "You do not have permision for this command!",
                ["Disabled"] = "This feature is currently disabled.",
                ["Failed"] = "Your report failed to send, contact the server owner.",
                ["ToSelf"] = "You cannot perform this action on yourself.",
                ["ReportTooShort"] = "Your report was too short! Please be more descriptive.",
                ["PlayerChatFormat"] = "**{0}:** {1}",
                ["BanPrefix"] = "Banned: {0}",
                ["Embed_ReportPlayer"] = "Reporter",
                ["Embed_ReportTarget"] = "Reported",
                ["Embed_ReportCount"] = "Times Reported",
                ["Embed_ReportReason"] = "Reason",
                ["Embed_Online"] = "Online",
                ["Embed_Offline"] = "Offline",
                ["Embed_ReportStatus"] = "Status",
                ["Embed_ReportTitle"] = "Player Report",
                ["Embed_MuteTitle"] = "Player Muted",
                ["Embed_MuteTarget"] = "Player",
                ["Embed_MutePlayer"] = "Muted by",
                ["Embed_BanPlayer"] = "Banned by",
                ["Embed_BanTarget"] = "Player",
                ["Embed_BanReason"] = "Reason",
                ["Embed_BanTitle"] = "Player Ban",
                ["Embed_MessageTitle"] = "Player Message",
                ["Embed_MessagePlayer"] = "Player",
                ["Embed_MessageMessage"] = "Message",
                ["Embed_MuteTime"] = "Time",
                ["Embed_MuteReason"] = "Reason"
            }, this);
        }

        #endregion

        #region Permissions

        private const string BanPermission = "discordmessages.ban";
        private const string ReportPermission = "discordmessages.report";
        private const string MessagePermission = "discordmessages.message";
        private const string AdminPermission = "discordmessages.admin";

        private void RegisterPermissions()
        {
            permission.RegisterPermission(BanPermission, this);
            permission.RegisterPermission(ReportPermission, this);
            permission.RegisterPermission(MessagePermission, this);
            permission.RegisterPermission(AdminPermission, this);
        }

        #endregion

        #region API

        private void API_SendFancyMessage(string webhookUrl, string embedName, int embedColor, string json, string content = null, Plugin plugin = null)
        {
            var builder = new EmbedBuilder()
                .WithTitle(embedName)
                .SetColor(embedColor);
            foreach (var field in JsonConvert.DeserializeObject<EmbedBuilder.Field[]>(json)) builder.AddField(field);
            var payload = new FancyMessage()
                .SetEmbed(builder)
                .WithContent(content);
            Request.Send(webhookUrl, payload, plugin);
        }

        private void API_SendFancyMessage(string webhookUrl, string embedName, string json, string content = null, int embedColor = 3329330, Plugin plugin = null)
        {
            API_SendFancyMessage(webhookUrl, embedName, embedColor, json, content, plugin);
        }

        private void API_SendTextMessage(string webhookUrl, string content, bool tts = false, Plugin plugin = null)
        {
            Request.Send(webhookUrl, new FancyMessage().AsTTS(tts).WithContent(content), plugin);
        }

        #endregion

        #region Report

        private void ReportAdminCommand(IPlayer player, string command, string[] args)
        {
            var target = GetPlayer(args[1], player, false);
            if (target == null)
            {
                player.Reply(GetLang("NotFound", player.Id, args[1]));
                return;
            }

            switch (args[0])
            {
                case "enable":
                    if (_data.Players.ContainsKey(target.Id)) _data.Players[target.Id].ReportDisabled = false;
                    player.Reply(GetLang("ReportAccessChanged", player.Id, target.Name, "enabled"));
                    return;
                case "disable":
                    if (_data.Players.ContainsKey(target.Id))
                        _data.Players[target.Id].ReportDisabled = true;
                    else
                        _data.Players.Add(target.Id, new PlayerData {ReportDisabled = true});
                    player.Reply(GetLang("ReportAccessChanged", player.Id, target.Name, "disabled"));
                    return;
                case "reset":
                    if (_data.Players.ContainsKey(target.Id))
                        if (_data.Players[target.Id].Reports != 0)
                        {
                            _data.Players[target.Id].Reports = 0;
                            player.Reply(GetLang("ReportReset", player.Id, target.Name));
                            return;
                        }

                    player.Reply(GetLang("NoReports", player.Id, target.Name));
                    return;
            }
        }

        private void ReportCommand(IPlayer player, string command, string[] args)
        {
            if ((player.Name == "Server Console") | !player.IsConnected) return;
            if (_data.Players.ContainsKey(player.Id))
            {
                if (_data.Players[player.Id].ReportDisabled)
                {
                    SendMessage(player, GetLang("ReportDisallowed", player.Id));
                    return;
                }
            }
            else
            {
                _data.Players.Add(player.Id, new PlayerData());
            }

            if (args.Length < 2)
            {
                SendMessage(player, GetLang("ReportSyntax", player.Id));
                return;
            }

            var reportConfig = GetFeatureConfig<Configuration.Report>(FeatureType.Report);
            if (OnCooldown(player, CooldownType.ReportCooldown))
            {
                var reportCooldown = _data.Players[player.Id].ReportCooldown;
                if (reportCooldown != null)
                    SendMessage(player,
                        GetLang("Cooldown", player.Id,
                            (reportCooldown.Value.AddSeconds(reportConfig.Cooldown) -
                             DateTime.UtcNow).Seconds));
                return;
            }

            var target = GetPlayer(args[0], player, true);
            if (target == null) return;

            var reason = args.Skip(1).ToList();
            if (player.Id == target.Id)
            {
                SendMessage(player, GetLang("ToSelf", player.Id));
                return;
            }

            var targetName = target.Name.Split(' ');
            if (targetName.Length > 1)
                for (var x = 0; x < targetName.Length - 1; x++)
                    if (reason[x].Equals(targetName[x + 1]))
                        reason.RemoveAt(x);
                    else
                        break;
            if (reason.Count < 1)
            {
                SendMessage(player, GetLang("ReportTooShort", player.Id));
                return;
            }

            var cleanReason = string.Join(" ", reason.ToArray());
            if (_data.Players.ContainsKey(target.Id))
            {
                _data.Players[target.Id].Reports++;
            }
            else
            {
                _data.Players.Add(target.Id, new PlayerData());
                _data.Players[target.Id].Reports++;
            }

            var status = target.IsConnected ? lang.GetMessage("Online", null) : lang.GetMessage("Offline", null);
            var builder = new EmbedBuilder()
                .WithTitle(GetLang("Embed_MessageTitle"))
                .SetColor(reportConfig.Color)
                .AddInlineField(GetLang("Embed_ReportTarget"), $"[{target.Name}](https://steamcommunity.com/profiles/{target.Id})")
                .AddInlineField(GetLang("Embed_ReportPlayer"), $"[{player.Name}](https://steamcommunity.com/profiles/{player.Id})")
                .AddInlineField(GetLang("Embed_ReportStatus"), status)
                .AddField(GetLang("Embed_ReportReason"), cleanReason)
                .AddInlineField(GetLang("Embed_ReportCount"), _data.Players[target.Id].Reports.ToString());
            var payload = new FancyMessage()
                .WithContent(reportConfig.Alert)
                .SetEmbed(builder);
            Request.Send(reportConfig.WebhookUrl, payload, response =>
            {
                if (response.IsOk)
                {
                    SendMessage(player, GetLang("ReportSent", player.Id));
                    if (_data.Players.ContainsKey(player.Id))
                    {
                        _data.Players[player.Id].ReportCooldown = DateTime.UtcNow;
                    }
                    else
                    {
                        _data.Players.Add(player.Id, new PlayerData());
                        _data.Players[player.Id].ReportCooldown = DateTime.UtcNow;
                    }

                    if (reportConfig.LogToConsole) Puts($"REPORT ({player.Name}/{player.Id}) -> ({target.Name}/{target.Id}): {reason}");
                }
                else if (response.IsBad)
                {
                    SendMessage(player, GetLang("ReportNotSent", player.Id));
                }
            }, this);
        }

        #endregion

        #region Mutes

        private static string FormatTime(TimeSpan time)
        {
            return $"{(time.Days == 0 ? string.Empty : $"{time.Days} day(s)")}{(time.Days != 0 && time.Hours != 0 ? ", " : string.Empty)}{(time.Hours == 0 ? string.Empty : $"{time.Hours} hour(s)")}{(time.Hours != 0 && time.Minutes != 0 ? ", " : string.Empty)}{(time.Minutes == 0 ? string.Empty : $"{time.Minutes} minute(s)")}{(time.Minutes != 0 && time.Seconds != 0 ? ", " : string.Empty)}{(time.Seconds == 0 ? string.Empty : $"{time.Seconds} second(s)")}";
        }

        private void OnBetterChatTimeMuted(IPlayer target, IPlayer player, TimeSpan expireDate, string reason)
        {
            SendMute(target, player, expireDate, true, reason);
        }

        private void OnBetterChatMuted(IPlayer target, IPlayer player, string reason)
        {
            SendMute(target, player, TimeSpan.Zero, false, reason);
        }

        private void SendMute(IPlayer target, IPlayer player, TimeSpan expireDate, bool timed, string reason)
        {
            if (target == null || player == null) return;
            var muteConfig = GetFeatureConfig<Configuration.Mute>(FeatureType.Mute);
            var builder = new EmbedBuilder()
                .WithTitle(GetLang("Embed_MuteTitle"))
                .AddInlineField(GetLang("Embed_MuteTarget"), $"[{target.Name}](https://steamcommunity.com/profiles/{target.Id})")
                .AddInlineField(GetLang("Embed_MutePlayer"), !player.Id.Equals("server_console") ? $"[{player.Name}](https://steamcommunity.com/profiles/{player.Id})" : player.Name)
                .AddInlineField(GetLang("Embed_MuteTime"), timed ? FormatTime(expireDate) : "Permanent")
                .SetColor(muteConfig.Color);
            if (!string.IsNullOrEmpty(reason)) builder.AddField(GetLang("Embed_MuteReason"), reason);
            var message = new FancyMessage()
                .SetEmbed(builder);
            Request.Send(muteConfig.WebhookUrl, message, this);
        }

        #endregion

        #region Bans

        private bool _banFromCommand;

        private void BanCommand(IPlayer player, string command, string[] args)
        {
            if (args.Length == 0)
            {
                SendMessage(player, GetLang("BanSyntax", player.Id));
                return;
            }

            var reason = args.Length == 1 ? "Banned" : string.Join(" ", args.Skip(1).ToArray());
            var target = GetPlayer(args[0], player, false);
            if (target != null)
            {
                if (target.Id == player.Id)
                {
                    SendMessage(player, GetLang("ToSelf", player.Id));
                    return;
                }

                ExecuteBan(target, player, reason);
            }
            else
            {
                player.Reply(GetLang("NotFound", player.Id, args[0]));
            }
        }

        private void ExecuteBan(IPlayer target, IPlayer player, string reason)
        {
            if (target.IsBanned)
            {
                SendMessage(player, GetLang("AlreadyBanned", player.Id, target.Name));
                return;
            }

            _banFromCommand = true;
            OnUserBanned(target.Name, target.Id, target.Address, reason, player);
            target.Ban(GetLang("BanPrefix", target.Id) + reason);
            if (_config.GeneralSettings.Announce) server.Broadcast(GetLang("BanMessage", null, target.Name, reason));
        }

        private void OnUserBanned(string name, string bannedId, string address, string reason, IPlayer source = null)
        {
            var banConfig = GetFeatureConfig<Configuration.Ban>(FeatureType.Ban);
            if (!banConfig.Enabled) return;
            var builder = new EmbedBuilder()
                .WithTitle(GetLang("Embed_BanTitle"))
                .AddInlineField(GetLang("Embed_BanTarget"), $"[{name}](https://steamcommunity.com/profiles/{bannedId})");
            if (source == null)
            {
                if (_banFromCommand) return;
            }
            else
            {
                builder.AddInlineField(GetLang("Embed_BanPlayer"), !source.Id.Equals("server_console") ? $"[{source.Name}](https://steamcommunity.com/profiles/{source.Id})" : source.Name);
            }

            builder.AddField(GetLang("Embed_BanReason"), reason)
                .SetColor(banConfig.Color);
            var message = new FancyMessage()
                .SetEmbed(builder);
            Request.Send(banConfig.WebhookUrl, message, this);
            _banFromCommand = false;
        }

        #endregion

        #region Helpers

        private string GetLang(string key, string id = null, params object[] args)
        {
            return args.Length > 0 ? string.Format(lang.GetMessage(key, this, id), args) : lang.GetMessage(key, this, id);
        }

        private void SendMessage(IPlayer player, string message)
        {
            player.Reply(message);
        }

        private bool OnCooldown(IPlayer player, CooldownType type)
        {
            if (_data.Players.ContainsKey(player.Id))
            {
                var playerData = _data.Players[player.Id];
                switch (type)
                {
                    case CooldownType.MessageCooldown:
                    {
                        if (playerData.MessageCooldown.HasValue) return playerData.MessageCooldown.Value.AddSeconds(GetFeatureConfig<Configuration.Message>(FeatureType.Message).Cooldown) > DateTime.UtcNow;
                        break;
                    }
                    case CooldownType.ReportCooldown:
                    {
                        if (playerData.ReportCooldown.HasValue) return playerData.ReportCooldown.Value.AddSeconds(GetFeatureConfig<Configuration.Report>(FeatureType.Report).Cooldown) > DateTime.UtcNow;
                        break;
                    }
                }
            }

            return false;
        }

        private void SaveData()
        {
            Interface.Oxide.DataFileSystem.WriteObject(Name, _data);
        }

        private void LoadData()
        {
            _data = Interface.Oxide.DataFileSystem.ReadObject<Data>(Name);
        }

        private IPlayer GetPlayer(string nameOrId, IPlayer player, bool sendError)
        {
            if (nameOrId.IsSteamId())
            {
                var result = players.All.ToList().Find(p => p.Id == nameOrId);

                return result;
            }

            var foundPlayers = new List<IPlayer>();

            foreach (var current in players.Connected)
            {
                if (string.Equals(current.Name, nameOrId, StringComparison.CurrentCultureIgnoreCase)) return current;

                if (current.Name.ToLower().Contains(nameOrId.ToLower())) foundPlayers.Add(current);
            }

            if (foundPlayers.Count == 0)
                foreach (var all in players.All)
                {
                    if (string.Equals(all.Name, nameOrId, StringComparison.CurrentCultureIgnoreCase)) return all;

                    if (all.Name.ToLower().Contains(nameOrId.ToLower())) foundPlayers.Add(all);
                }

            switch (foundPlayers.Count)
            {
                case 0:
                    if (!nameOrId.IsSteamId())
                        if (sendError)
                            SendMessage(player, GetLang("NotFound", player.Id, nameOrId));

                    break;

                case 1:
                    return foundPlayers[0];

                default:
                    var names = (from current in foundPlayers select current.Name).ToArray();
                    SendMessage(player, GetLang("Multiple", player.Id, string.Join(", ", names)));
                    break;
            }

            return null;
        }

        #endregion
    }
}
# frozen_string_literal: true

require "set"

# Each docs version lives once in `_docs/<version>/` with its sidebar in `_data/docs/<version_with_underscores>.yml`.
# The `latest` & `next` versions in `_data/versions.yml` are also served at `/docs/` & `/docs/next/`.
module DocsVersions
  class Generator < Jekyll::Generator
    safe true
    priority :highest

    def generate(site)
      collection = site.collections["docs"]
      return unless collection

      settings = site.data["versions"] || {}
      latest = settings["latest"].to_s
      upcoming = settings["next"].to_s
      navs = site.data["docs"] || {}
      versions = collection.docs.filter_map { |doc| version_of(doc, collection) }.uniq
      versions = versions.sort_by { |version| Gem::Version.new(version) }.reverse
      navigation = (site.data["navigation"] ||= {})

      versions.each { |version| navigation[nav_key(version)] = navs[file_key(version)] }
      navigation["docs"] = rewrite(navs[file_key(latest)], latest, "/docs/") if versions.include?(latest)
      navigation["docs_next"] = rewrite(navs[file_key(upcoming)], upcoming, "/docs/next/") if versions.include?(upcoming)

      collection.docs.dup.each do |doc|
        version = version_of(doc, collection)
        next unless version

        tag(doc, version, "/docs/#{version}/", nav_key(version))
        collection.docs << alias_of(site, doc, version, "/docs/", "docs") if version == latest
        collection.docs << alias_of(site, doc, version, "/docs/next/", "docs_next") if version == upcoming
      end

      urls = collection.docs.map(&:url).to_set
      collection.docs.each do |doc|
        version = doc.data["docs_version"]
        next unless version

        path = doc.url.delete_prefix(doc.data["docs_base"])
        doc.data["docs_versions"] = versions.map do |other|
          {
            "label" => label(other, latest, upcoming),
            "url" => find(urls, base(other, latest, upcoming), path),
            "selected" => other == version,
          }
        end
        doc.data["docs_latest_url"] = find(urls, base(latest, latest, upcoming), path)
        if version == upcoming
          doc.data["docs_banner"] = "next"
        elsif version == latest
          doc.data["docs_banner"] = "latest"
        elsif !latest.empty? && Gem::Version.new(version) < Gem::Version.new(latest)
          doc.data["docs_banner"] = "old"
        end
      end
    end

    private

    def version_of(doc, collection)
      relative = doc.path.delete_prefix(collection.directory).delete_prefix("/").delete_prefix("\\")
      version = relative.split(%r{[/\\]}).first
      version if Gem::Version.correct?(version)
    end

    def tag(doc, version, docs_base, nav)
      doc.data["docs_version"] = version
      doc.data["docs_base"] = docs_base
      doc.data["sidebar"] = { "nav" => nav }
    end

    def alias_of(site, doc, version, docs_base, nav)
      copy = Jekyll::Document.new(doc.path, :site => site, :collection => doc.collection)
      copy.read
      from = "/docs/#{version}/"
      copy.content = copy.content.gsub(from, docs_base)
      copy.data["permalink"] = doc.url.sub(from, docs_base)
      tag(copy, version, docs_base, nav)
      copy
    end

    def rewrite(value, version, docs_base)
      case value
      when Array then value.map { |item| rewrite(item, version, docs_base) }
      when Hash then value.transform_values { |item| rewrite(item, version, docs_base) }
      when String then value.sub("/docs/#{version}/", docs_base)
      else value
      end
    end

    def find(urls, docs_base, path)
      url = docs_base + path
      urls.include?(url) ? url : docs_base
    end

    def base(version, latest, upcoming)
      return "/docs/" if version == latest
      return "/docs/next/" if version == upcoming

      "/docs/#{version}/"
    end

    def label(version, latest, upcoming)
      return "#{version}-SNAPSHOT" if version == upcoming
      return "#{version} (latest)" if version == latest

      version
    end

    def file_key(version)
      version.tr(".", "_")
    end

    def nav_key(version)
      "docs_#{file_key(version)}"
    end
  end
end
